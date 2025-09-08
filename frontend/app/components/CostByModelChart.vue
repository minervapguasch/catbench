<template>
  <div class="card bg-base-100 shadow-xl">
    <div class="card-body">
      <h2 class="card-title text-lg">Cost by model</h2>
      <p class="opacity-70">Estimated total cost per model</p>
      <div class="mt-4">
        <ClientOnly>
          <apexchart type="bar" height="360" :options="options" :series="series" />
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

const { costfulModels } = useModelMetrics(props.models)

const sorted = computed(() => [...costfulModels].sort((a, b) => (b.__cost_usd as number) - (a.__cost_usd as number)))
const categories = computed(() => sorted.value.map(m => m.model))
const values = computed(() => sorted.value.map(m => Number((m.__cost_usd as number).toFixed(4))))

const series = computed(() => [{ name: 'Cost (USD)', data: values.value }])

const options = computed(() => ({
  chart: { toolbar: { show: false }, foreColor: baseContent(), background: 'transparent' },
  grid: { borderColor: base300() },
  theme: { mode: 'dark' },
  xaxis: { categories: categories.value, labels: { rotate: -45, trim: true } },
  yaxis: { labels: { formatter: (v: number) => `$${v.toFixed(3)}` } },
  plotOptions: { bar: { borderRadius: 6, columnWidth: '40%' } },
  dataLabels: { enabled: true, formatter: (v: number) => `$${v.toFixed(3)}` },
  colors: [primary()],
}))
</script>


