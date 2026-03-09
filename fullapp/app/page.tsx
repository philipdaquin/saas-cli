import Link from 'next/link'

export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-24">
      <div className="text-center">
        <h1 className="text-4xl font-bold mb-4">Welcome to fullapp</h1>
        <p className="text-gray-600 mb-8">Built with saas-cli</p>
        <div className="flex gap-4 justify-center">
          <Link href="/login" className="px-6 py-3 bg-primary text-primary-foreground rounded-lg hover:bg-primary/90">
            Get Started
          </Link>
          <Link href="/pricing" className="px-6 py-3 border border-gray-300 rounded-lg hover:bg-gray-50">
            View Pricing
          </Link>
        </div>
      </div>
    </main>
  )
}