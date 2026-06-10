-- Create or replace the player dues summary view with security_invoker = on
-- This ensures the view inherits the Row Level Security (RLS) policies of the underlying `payment_dues` table.
CREATE OR REPLACE VIEW public.v_player_dues_summary WITH (security_invoker = on) AS
SELECT 
    group_id,
    player_id,
    CAST(SUM(amount_paise) AS integer) AS pending_paise,
    CAST(COUNT(id) AS integer) AS unpaid_count
FROM 
    public.payment_dues
WHERE 
    status != 'paid'
GROUP BY 
    group_id, 
    player_id;

-- Add descriptive comment
COMMENT ON VIEW public.v_player_dues_summary IS 'Summary of unpaid dues per player per group, respecting RLS of payment_dues via security_invoker';