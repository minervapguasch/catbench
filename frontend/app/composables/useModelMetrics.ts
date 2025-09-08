export type BenchmarkModel = {
  model: string
  summary: {
    total: number
    corrects: number
    accuracy_percentage: number
    avg_latency_ms?: number
    cost_usd?: number
    cost_total_usd?: number
    cost?: number
    tokens?: { total?: number; prompt?: number; completion?: number }
  }
  results?: Array<{ latency_ms?: number; price?: number }>
}

export function useModelMetrics(models: BenchmarkModel[]) {
  const getLatency = (m: BenchmarkModel): number | null => {
    if (typeof m.summary.avg_latency_ms === 'number') return m.summary.avg_latency_ms
    if (m.results && m.results.length) {
      const latencies = m.results.map(r => r.latency_ms).filter((v): v is number => typeof v === 'number')
      if (latencies.length) return Math.round(latencies.reduce((a, b) => a + b, 0) / latencies.length)
    }
    return null
  }

  const getCost = (m: BenchmarkModel): number | null => {
    // Prefer explicit summary costs if present
    const c = m.summary.cost_usd ?? m.summary.cost_total_usd ?? m.summary.cost
    if (typeof c === 'number') return c
    // Fallback: sum per-result price if provided by the pipeline
    if (m.results && m.results.length) {
      const prices = m.results.map(r => r.price).filter((v): v is number => typeof v === 'number')
      if (prices.length) {
        const total = prices.reduce((a, b) => a + b, 0)
        return +total.toFixed(6)
      }
    }
    return null
  }

  const withLatency = models.map(m => ({ ...m, __latency_ms: getLatency(m) }))
  const withCost = withLatency.map(m => ({ ...m, __cost_usd: getCost(m) }))

  return {
    modelsWithMetrics: withCost,
    costfulModels: withCost.filter(m => typeof m.__cost_usd === 'number'),
    latencyModels: withCost.filter(m => typeof m.__latency_ms === 'number'),
  }
}


