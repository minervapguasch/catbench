<template>
  <div class="card bg-base-100 shadow-xl">
    <div class="card-body">
      <h2 class="card-title text-lg">Success rate by model</h2>
      <p class="opacity-70">Percentage of correct answers per model</p>
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

type BenchmarkModel = {
  model: string
  summary: { total: number; corrects: number; accuracy_percentage: number }
}

const props = defineProps<{ models: BenchmarkModel[] }>()

const { primary, baseContent, base300 } = useDaisyColors()

const sorted = computed(() =>
  [...props.models].sort((a, b) => b.summary.accuracy_percentage - a.summary.accuracy_percentage)
)
const categories = computed(() => sorted.value.map(m => m.model))
const values = computed(() => sorted.value.map(m => m.summary.accuracy_percentage))

const series = computed(() => [{ name: 'Accuracy %', data: values.value }])

const options = computed(() => ({
  chart: { toolbar: { show: false }, foreColor: baseContent(), background: 'transparent' },
  grid: { borderColor: base300() },
  theme: { mode: 'dark' },
  xaxis: {
    categories: categories.value,
    labels: { rotate: -45, trim: true, hideOverlappingLabels: true },
  },
  yaxis: {
    max: 100,
    labels: { formatter: (v: number) => `${v}%` },
  },
  plotOptions: {
    bar: { borderRadius: 6, columnWidth: '40%', distributed: true }
  },
  dataLabels: { enabled: true, formatter: (v: number) => `${v.toFixed(1)}%` },
  colors: categories.value.map((_, i) => [primary(), '#22c55e', '#f59e0b', '#10b981', '#06b6d4', '#8b5cf6', '#ef4444'][i % 7]),
  tooltip: { y: { formatter: (v: number) => `${v}%` } }
}))
</script>


