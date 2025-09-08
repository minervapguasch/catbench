<template>
  <div class="card bg-base-100 shadow-xl">
    <div class="card-body">
      <h2 class="card-title text-lg">Cost vs Accuracy</h2>
      <p class="opacity-70">Each point is a model. Lower cost and higher accuracy is better.</p>
      <div class="mt-4">
        <ClientOnly>
          <apexchart type="scatter" height="420" :options="options" :series="series" />
        </ClientOnly>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useDaisyColors } from '~/composables/useDaisyColors'
import { useModelMetrics, type BenchmarkModel } from '~/composables/useModelMetrics'

const props = defineProps<{ models: BenchmarkModel[] }>()
const { primary, baseContent, base300 } = useDaisyColors()

const { modelsWithMetrics } = useModelMetrics(props.models)

const points = computed(() => modelsWithMetrics
  .filter(m => typeof m.__cost_usd === 'number')
  .map(m => ({ x: Number((m.__cost_usd as number).toFixed(4)), y: m.summary.accuracy_percentage, name: m.model })))

const series = computed(() => [{ name: 'Models', data: points.value }])

const options = computed(() => ({
  chart: { toolbar: { show: false }, foreColor: baseContent(), background: 'transparent' },
  grid: { borderColor: base300() },
  theme: { mode: 'dark' },
  xaxis: { title: { text: 'Cost (USD)' }, labels: { formatter: (v: number) => `$${v.toFixed(3)}` } },
  yaxis: { title: { text: 'Accuracy %' }, max: 100, labels: { formatter: (v: number) => `${v}%` } },
  markers: { size: 6 },
  dataLabels: { enabled: false },
  tooltip: {
    y: { formatter: (v: number) => `${v}%` },
    x: { formatter: (v: number) => `$${Number(v).toFixed(3)}` },
    custom: ({ seriesIndex, dataPointIndex, w }: any) => {
      const point = w.globals.initialSeries[seriesIndex].data[dataPointIndex]
      return `<div class="p-2"><div class="font-semibold">${point.name}</div><div>Accuracy: ${point.y}%</div><div>Cost: $${Number(point.x).toFixed(3)}</div></div>`
    }
  },
  colors: [primary()],
}))
</script>


