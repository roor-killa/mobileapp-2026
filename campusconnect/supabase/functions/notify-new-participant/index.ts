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
  // record = { id, event_id, user_id (celui qui a rejoint) }

  // 1. Récupérer l'événement et son organisateur
  const { data: event } = await supabase
    .from('events')
    .select('organisateur_id, titre')
    .eq('id', record.event_id)
    .maybeSingle()

  if (!event) return new Response('no event', { status: 200 })

  // Pas de notification si l'organisateur rejoint son propre événement
  if (event.organisateur_id === record.user_id) {
    return new Response('self-join', { status: 200 })
  }

  // 2. Récupérer le token FCM de l'organisateur
  const { data: organizer } = await supabase
    .from('users')
    .select('fcm_token')
    .eq('id', event.organisateur_id)
    .maybeSingle()

  if (!organizer?.fcm_token) return new Response('no token', { status: 200 })

  // 3. Récupérer le nom du participant
  const { data: participant } = await supabase
    .from('users')
    .select('nom')
    .eq('id', record.user_id)
    .maybeSingle()

  const participantName = participant?.nom ?? 'Quelqu\'un'
  const eventTitle = event.titre.length > 40
    ? event.titre.substring(0, 40) + '…'
    : event.titre

  await sendFcm(
    organizer.fcm_token,
    '🎉 Nouveau participant',
    `${participantName} a rejoint "${eventTitle}"`
  )

  return new Response('ok', { status: 200 })
})
