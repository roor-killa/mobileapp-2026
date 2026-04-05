import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)

async function sendFcm(token: string, title: string, body: string) {
  const key = Deno.env.get('FCM_SERVER_KEY')!
  await fetch('https://fcm.googleapis.com/fcm/send', {
    method: 'POST',
    headers: {
      Authorization: `key=${key}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      to: token,
      notification: { title, body },
      android: { priority: 'high' },
    }),
  })
}

Deno.serve(async (req) => {
  const { record } = await req.json()
  // record = { id, conversation_id, expediteur_id, contenu, ... }

  // 1. Trouver le destinataire (l'autre participant de la conversation)
  const { data: participants } = await supabase
    .from('conversation_participants')
    .select('user_id')
    .eq('conversation_id', record.conversation_id)
    .neq('user_id', record.expediteur_id)

  if (!participants || participants.length === 0) {
    return new Response('no recipient', { status: 200 })
  }
  const recipientId = participants[0].user_id

  // 2. Récupérer le token FCM du destinataire
  const { data: recipient } = await supabase
    .from('users')
    .select('fcm_token')
    .eq('id', recipientId)
    .maybeSingle()

  if (!recipient?.fcm_token) {
    return new Response('no token', { status: 200 })
  }

  // 3. Récupérer le nom de l'expéditeur
  const { data: sender } = await supabase
    .from('users')
    .select('nom')
    .eq('id', record.expediteur_id)
    .maybeSingle()

  const senderName = sender?.nom ?? 'Quelqu\'un'
  const body = record.contenu.length > 60
    ? record.contenu.substring(0, 60) + '…'
    : record.contenu

  await sendFcm(recipient.fcm_token, senderName, body)

  return new Response('ok', { status: 200 })
})
