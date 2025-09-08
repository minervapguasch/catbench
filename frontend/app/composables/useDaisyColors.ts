export function useDaisyColors() {
  const getVar = (name: string) => getComputedStyle(document.documentElement).getPropertyValue(name).trim()
  // Tailwind v4 + DaisyUI expose CSS vars like --p, --pc, --s, --sc, etc
  const colorFromVar = (cssVar: string, fallback: string) => {
    const val = getVar(cssVar)
    return val || fallback
  }

  const primary = () => colorFromVar('--p', '#6366f1')
  const secondary = () => colorFromVar('--s', '#22c55e')
  const accent = () => colorFromVar('--a', '#ef4444')
  const baseContent = () => colorFromVar('--bc', '#e5e7eb')
  const base300 = () => colorFromVar('--b3', '#2a2e37')

  return { primary, secondary, accent, baseContent, base300 }
}


