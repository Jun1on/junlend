'use client'
import Image from 'next/image'
import { useEffect, useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'

const protocols = ['Aave', 'Compound', 'Morpho', 'Fluid', 'Euler']

export default function HomePage() {
  const [currentProtocol, setCurrentProtocol] = useState(0)

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentProtocol((prev) => (prev + 1) % protocols.length)
    }, 2500)

    return () => clearInterval(interval)
  }, [])

  return (
    <div
      className='flex h-screen flex-col justify-between bg-cover bg-center text-white'
      style={{ backgroundImage: 'url("/background.png")' }}>
      <div className='flex flex-grow items-center justify-center'>
        <div className='max-w-4xl text-center'>
          <h1 className='mb-4 text-6xl font-bold'>The smarter way to borrow in DeFi.</h1>
          <ul className='mb-6 flex justify-center space-x-4'>
            <li>🌟 Guaranteed better rates</li>
            <li>🌟 Liquidation protection</li>
          </ul>

          <div className='mt-12 text-center'>
            <h2 className='mb-4 flex items-center justify-center text-2xl font-semibold'>
              Migrate your{' '}
              <motion.div
                key={protocols[currentProtocol]}
                className='mx-2 font-bold text-green-400'
                initial={{ opacity: 0, x: -30 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -30 }}
                transition={{ duration: 0.5 }}>
                {protocols[currentProtocol]}
              </motion.div>{' '}
              position.
            </h2>
            <button className='rounded-full bg-green-500 px-6 py-3 text-lg text-white transition hover:bg-green-600'>
              One-Click Migrate
            </button>
          </div>
        </div>
      </div>
      <div>
        <Image src='/background.svg' alt='Blockchain Icons' width={800} height={300} />
      </div>
    </div>
  )
}
