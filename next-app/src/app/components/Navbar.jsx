import React from 'react'
import Link from 'next/link'
import Image from '../../../node_modules/next/image'
import Logo from './dojo-logo.png'

export default function Navbar() {
  return (
    <nav>
        <Image 
        src={Logo}
        alt='Dojo HelpDesk logo'
        width={70}
        quality={100}
        placeholder='blur'
        />
        <h1>vvk Helpdesk</h1>
        <Link href="/">  Dashboard</Link>
        <Link href="/tickets">  Tickets</Link>
  </nav>
  )
}
