import { Button } from '@react-email/components'

export function WelcomeEmail({ name }: { name: string }) {
  return (
    <div>
      <h1>Welcome to Our App!</h1>
      <p>Hi {name}, thanks for signing up!</p>
      <Button href="https://yourapp.com/dashboard">Get Started</Button>
    </div>
  )
}