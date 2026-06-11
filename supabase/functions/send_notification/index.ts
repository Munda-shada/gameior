import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.7"
import { GoogleAuth } from "https://esm.sh/google-auth-library@9.4.1"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface NotificationPayload {
  type:          string;
  userId:        string;
  groupId?:      string;
  gameId?:       string;
  amountPaise?:  number;
  actorId?:      string;
  metadata?:     Record<string, unknown>;
}

function toIST(date: Date): Date {
  return new Date(date.getTime() + (5.5 * 60 * 60 * 1000));
}

function buildNotificationContent(payload: NotificationPayload): { title: string; body: string } {
  const formatRupees = (paise: number) => `₹${(paise / 100).toFixed(0)}`;
  
  switch (payload.type) {
    case 'join_request':
      return { 
        title: 'New Join Request', 
        body: 'Someone wants to join your group.' 
      };
    case 'join_approved':
      return { 
        title: 'Request Approved! 🎉', 
        body: "You've been added to the group." 
      };
    case 'join_rejected':
      return { 
        title: 'Request Declined', 
        body: 'Your join request was not approved.' 
      };
    case 'waitlist_promotion':
      return { 
        title: "You're In! 🟢", 
        body: "A spot opened up — you've been confirmed." 
      };
    case 'dues_generated':
      return { 
        title: 'Payment Due', 
        body: `You owe ${formatRupees(payload.amountPaise!)} for your last session.` 
      };
    case 'dues_reminder':
      return { 
        title: 'Outstanding Dues Reminder', 
        body: `You have ${formatRupees(payload.amountPaise!)} in pending dues.` 
      };
    case 'payment_approved':
      return { 
        title: 'Payment Confirmed ✓', 
        body: 'Your payment has been approved.' 
      };
    case 'payment_rejected':
      return { 
        title: 'Payment Rejected', 
        body: 'Your payment reference was rejected. Please resubmit.' 
      };
    case 'game_cancelled':
      return { 
        title: 'Session Cancelled', 
        body: 'A session you were registered for has been cancelled.' 
      };
    case 'game_created':
      return {
        title: 'New Session Scheduled',
        body: 'A new game session has been added.'
      };
    case 'rsvp_reminder':
      return {
        title: 'RSVP Reminder',
        body: 'Do not forget to RSVP for the upcoming game!'
      };
    default:
      return { 
        title: 'Gameior', 
        body: 'You have a new update.' 
      };
  }
}

async function shouldDeliver(userId: string, type: string, supabase: any): Promise<'send' | 'digest' | 'suppress'> {
  const { data: profile, error } = await supabase
    .from('profiles')
    .select('notif_game_reminders, notif_waitlist_promotions, notif_payment_dues, notif_matchday_lineups, notif_delivery_mode')
    .eq('id', userId)
    .maybeSingle();

  if (error || !profile) {
    return 'send';
  }

  // Check if type is enabled
  let typeEnabled = true;
  if (type === 'game_created' || type === 'rsvp_reminder') {
    typeEnabled = profile.notif_game_reminders;
  } else if (type === 'waitlist_promotion') {
    typeEnabled = profile.notif_waitlist_promotions;
  } else if (type === 'dues_generated' || type === 'dues_reminder' || type === 'payment_submitted' || type === 'payment_approved' || type === 'payment_rejected') {
    typeEnabled = profile.notif_payment_dues;
  } else if (type === 'matchday_lineups') {
    typeEnabled = profile.notif_matchday_lineups;
  }

  if (!typeEnabled) return 'suppress';

  // Check delivery mode
  const nowIST = toIST(new Date());
  const hour = nowIST.getUTCHours(); // IST hours because we added the offset to UTC

  if (profile.notif_delivery_mode === 'daily_digest') {
    return 'digest';
  } else if (profile.notif_delivery_mode === 'quiet_hours') {
    // 10 PM to 8 AM quiet hours
    if (hour >= 22 || hour < 8) {
      return 'digest';
    }
  }

  return 'send';
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    );

    const payload: NotificationPayload = await req.json();
    if (!payload.userId || !payload.type) {
      return new Response(
        JSON.stringify({ error: 'validation_error', message: 'userId and type are required' }),
        { status: 422, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const { title, body } = buildNotificationContent(payload);

    // 1. Insert into notifications table (history log)
    const { error: insertError } = await supabaseAdmin
      .from('notifications')
      .insert({
        user_id: payload.userId,
        title,
        body,
        payload: {
          type: payload.type,
          group_id: payload.groupId,
          game_id: payload.gameId,
          amount_paise: payload.amountPaise,
          actor_id: payload.actorId,
          metadata: payload.metadata,
        },
      });

    if (insertError) {
      console.error('Failed to log notification:', insertError);
    }

    // 2. Check delivery preferences
    const delivery = await shouldDeliver(payload.userId, payload.type, supabaseAdmin);

    if (delivery === 'suppress') {
      return new Response(
        JSON.stringify({ data: { status: 'suppressed' } }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    if (delivery === 'digest') {
      // Queue it
      await supabaseAdmin.from('notification_digest_queue').insert({
        user_id: payload.userId,
        payload: {
          type: payload.type,
          title,
          body,
          group_id: payload.groupId,
          game_id: payload.gameId,
        },
      });

      return new Response(
        JSON.stringify({ data: { status: 'queued' } }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // 3. Dispatch via FCM
    const { data: tokens, error: tokensError } = await supabaseAdmin
      .from('notification_tokens')
      .select('fcm_token')
      .eq('user_id', payload.userId);

    if (tokensError || !tokens || tokens.length === 0) {
      return new Response(
        JSON.stringify({ data: { status: 'no_tokens' } }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const serviceAccountStr = Deno.env.get('FIREBASE_SERVICE_ACCOUNT') || '{}';
    const serviceAccount = JSON.parse(serviceAccountStr);
    const projectId = serviceAccount.project_id;

    if (!projectId) {
      console.warn('FIREBASE_SERVICE_ACCOUNT project_id is empty. Skipping FCM push.');
      return new Response(
        JSON.stringify({ data: { status: 'mock_sent', message: 'No firebase configuration' } }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const auth = new GoogleAuth({
      credentials: serviceAccount,
      scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
    });
    const client = await auth.getClient();
    const tokenResponse = await client.getAccessToken();
    const accessToken = tokenResponse.token;

    if (!accessToken) {
      throw new Error('Failed to obtain Google access token');
    }

    const url = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;
    
    for (const tokenRow of tokens) {
      const fcmToken = tokenRow.fcm_token;
      
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message: {
            token: fcmToken,
            notification: { title, body },
            data: {
              type: payload.type,
              group_id: payload.groupId || '',
              game_id: payload.gameId || '',
            },
            apns: {
              payload: {
                aps: {
                  sound: 'default',
                  badge: 1,
                },
              },
            },
          },
        }),
      });

      if (response.status === 404 || response.status === 410) {
        // Token is invalid, remove it
        await supabaseAdmin
          .from('notification_tokens')
          .delete()
          .eq('fcm_token', fcmToken);
      }
    }

    return new Response(
      JSON.stringify({ data: { status: 'sent', tokens_checked: tokens.length } }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );

  } catch (err) {
    return new Response(
      JSON.stringify({ error: 'internal_error', message: err.message || 'Unexpected server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
})
