'use client'
import { loadStripe } from '@stripe/stripe-js'

const plans = [
  { name: 'Basic', price: '$9/mo', priceId: 'price_basic' },
  { name: 'Pro', price: '$29/mo', priceId: 'price_pro' },
]

export default function PricingPage() {
  const handleSubscribe = async (priceId: string) => {
    const res = await fetch('/api/stripe/checkout', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ priceId }),
    })
    const { sessionId } = await res.json()
    const stripe = await loadStripe(process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY!)
    stripe?.redirectToCheckout({ sessionId })
  }

  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold text-center mb-8">Pricing</h1>
      <div className="flex justify-center gap-8">
        {plans.map(plan => (
          <div key={plan.name} className="border p-8 rounded-lg">
            <h2 className="text-xl font-bold">{plan.name}</h2>
            <p className="text-3xl font-bold my-4">{plan.price}</p>
            <button onClick={() => handleSubscribe(plan.priceId)} className="w-full bg-primary text-white p-2 rounded">
              Subscribe
            </button>
          </div>
        ))}
      </div>
    </div>
  )
}