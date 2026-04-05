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
  // record = { id, announcement_id, user_id (celui qui a liké) }

  // 1. Récupérer l'annonce et son propriétaire
  const { data: announcement } = await supabase
    .from('announcements')
    .select('user_id, titre')
    .eq('id', record.announcement_id)
    .maybeSingle()

  if (!announcement) return new Response('no announcement', { status: 200 })

  // Pas de notification si on like sa propre annonce
  if (announcement.user_id === record.user_id) {
    return new Response('self-like', { status: 200 })
  }

  // 2. Récupérer le token FCM du propriétaire de l'annonce
  const { data: owner } = await supabase
    .from('users')
    .select('fcm_token')
    .eq('id', announcement.user_id)
    .maybeSingle()

  if (!owner?.fcm_token) return new Response('no token', { status: 200 })

  // 3. Récupérer le nom de celui qui a liké
  const { data: liker } = await supabase
    .from('users')
    .select('nom')
    .eq('id', record.user_id)
    .maybeSingle()

  const likerName = liker?.nom ?? 'Quelqu\'un'
  const title = announcement.titre.length > 40
    ? announcement.titre.substring(0, 40) + '…'
    : announcement.titre

  await sendFcm(
    owner.fcm_token,
    '❤️ Nouveau favori',
    `${likerName} a ajouté "${title}" à ses favoris`
  )

  return new Response('ok', { status: 200 })
})
