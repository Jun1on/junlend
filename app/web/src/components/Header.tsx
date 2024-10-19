import { SITE_EMOJI } from '@/utils/site'
import { Connect } from './Connect'
import LinkComponent from './LinkComponent'
import { ThemeToggle } from './ThemeToggle'

export function Header() {
  return (
    <header className='navbar fixed left-0 right-0 top-0 z-10 flex justify-between p-4 pt-1'>
      <LinkComponent href='/'>
        <h1 className='text-xl font-bold'>{SITE_EMOJI} JunLend</h1>
      </LinkComponent>

      <div className='flex gap-2'>
        <Connect />
      </div>
    </header>
  )
}
