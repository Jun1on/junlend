import { SITE_EMOJI, SITE_INFO, SOCIAL_GITHUB, SOCIAL_TWITTER } from '@/utils/site'
import { FaGithub, FaXTwitter } from 'react-icons/fa6'
import LinkComponent from './LinkComponent'
import Image from 'next/image'

export function Footer() {
  return (
    <>
      <footer className='footer bg-neutral text-neutral-content fixed bottom-0 left-0 right-0 flex items-center justify-between p-4'>
        {/* <div className='flex flex-row gap-2'>
          <Image src='/icons/eth-icon.png' alt='Site Logo' height={24} width={24} /> {SITE_INFO}
        </div> */}
        <div className='flex gap-4'>
          <LinkComponent href={`https://github.com/${SOCIAL_GITHUB}`}>
            <FaGithub />
          </LinkComponent>
          <LinkComponent href={`https://x.com/${SOCIAL_TWITTER}`}>
            <FaXTwitter />
          </LinkComponent>
        </div>
      </footer>
    </>
  )
}
