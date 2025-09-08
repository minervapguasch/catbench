<template>
  <div class="card bg-base-100 shadow-xl">
    <div class="card-body">
      <h2 class="card-title text-lg">Speed by model</h2>
      <p class="opacity-70">Lower is faster (average latency in ms)</p>
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
const { accent, baseContent, base300 } = useDaisyColors()

const { latencyModels } = useModelMetrics(props.models)

const sorted = computed(() => [...latencyModels].sort((a, b) => (a.__latency_ms as number) - (b.__latency_ms as number)))
const categories = computed(() => sorted.value.map(m => m.model))
const values = computed(() => sorted.value.map(m => m.__latency_ms as number))

const series = computed(() => [{ name: 'Avg latency (ms)', data: values.value }])

const options = computed(() => ({
  chart: { toolbar: { show: false }, foreColor: baseContent(), background: 'transparent' },
  grid: { borderColor: base300() },
  theme: { mode: 'dark' },
  xaxis: { categories: categories.value, labels: { rotate: -45, trim: true } },
  yaxis: { reversed: true },
  plotOptions: { bar: { borderRadius: 6, columnWidth: '40%' } },
  dataLabels: { enabled: true, formatter: (v: number) => `${v.toFixed(0)}ms` },
  colors: [accent()],
}))
</script>


