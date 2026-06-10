import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.7"
import { GoogleAuth } from "https://esm.sh/google-auth-library@9.4.1"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
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

    // 1. Fetch all items in the digest queue
    const { data: queueItems, error: queueError } = await supabaseAdmin
      .from('notification_digest_queue')
      .select('*')
      .order('created_at', { ascending: true });

    if (queueError) {
      throw queueError;
    }

    if (!queueItems || queueItems.length === 0) {
      return new Response(
        JSON.stringify({ data: { status: 'empty', message: 'No queued notifications to send.' } }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // 2. Group items by user_id
    const userItemsMap = new Map<string, any[]>();
    for (const item of queueItems) {
      const uId = item.user_id;
      if (!userItemsMap.has(uId)) {
        userItemsMap.set(uId, []);
      }
      userItemsMap.get(uId)!.push(item);
    }

    // 3. Initialize Firebase Auth
    const serviceAccountStr = Deno.env.get('FIREBASE_SERVICE_ACCOUNT') || '{}';
    const serviceAccount = JSON.parse(serviceAccountStr);
    const projectId = serviceAccount.project_id;

    let accessToken = '';
    if (projectId) {
      const auth = new GoogleAuth({
        credentials: serviceAccount,
        scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
      });
      const client = await auth.getClient();
      const tokenResponse = await client.getAccessToken();
      accessToken = tokenResponse.token || '';
    }

    const url = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;
    let dispatchedCount = 0;

    // 4. Process each user's queued notifications
    for (const [userId, items] of userItemsMap.entries()) {
      // Determine title, body and data fields
      let title = 'Gameior Digest';
      let body = `You have ${items.length} new updates. Tap to review.`;
      let type = 'digest';
      let groupId = '';
      let gameId = '';

      if (items.length === 1) {
        const payload = items[0].payload;
        title = payload.title || title;
        body = payload.body || body;
        type = payload.type || type;
        groupId = payload.group_id || '';
        gameId = payload.game_id || '';
      }

      // Query user's FCM tokens
      const { data: tokens } = await supabaseAdmin
        .from('notification_tokens')
        .select('fcm_token')
        .eq('user_id', userId);

      if (tokens && tokens.length > 0 && accessToken && projectId) {
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
                  type,
                  group_id: groupId,
                  game_id: gameId,
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
            // Delete invalid token
            await supabaseAdmin
              .from('notification_tokens')
              .delete()
              .eq('fcm_token', fcmToken);
          }
        }
      }

      // 5. Clear queued items for this user
      const itemIds = items.map(i => i.id);
      await supabaseAdmin
        .from('notification_digest_queue')
        .delete()
        .in('id', itemIds);

      dispatchedCount++;
    }

    return new Response(
      JSON.stringify({ data: { status: 'success', users_processed: dispatchedCount } }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );

  } catch (err) {
    return new Response(
      JSON.stringify({ error: 'internal_error', message: err.message || 'Unexpected server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
})
