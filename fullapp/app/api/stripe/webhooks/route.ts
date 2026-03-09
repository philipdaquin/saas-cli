import { NextRequest, NextResponse } from 'next/server'
import { stripe } from '@/lib/stripe'
import { headers } from 'next/headers'

export async function POST(req: NextRequest) {
  const body = await req.text()
  const signature = headers().get('stripe-signature')!

  let event
  try {
    event = stripe.webhooks.constructEvent(body, signature, process.env.STRIPE_WEBHOOK_SECRET!)
  } catch (err) {
    return NextResponse.json({ error: 'Webhook signature verification failed' }, { status: 400 })
  }

  switch (event.type) {
    case 'checkout.session.completed':
      console.log('Checkout completed:', event.data.object)
      break
    case 'customer.subscription.created':
      console.log('Subscription created:', event.data.object)
      break
    case 'customer.subscription.deleted':
      console.log('Subscription cancelled:', event.data.object)
      break
  }

  return NextResponse.json({ received: true })
}