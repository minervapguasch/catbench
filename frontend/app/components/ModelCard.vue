<template>
  <div class="card bg-base-100 shadow-lg">
    <div class="card-body">
      <div class="flex items-center justify-between">
        <h3 class="card-title text-base md:text-lg truncate">{{ model.summary ? modelName : '' }}</h3>
        <div class="badge badge-success badge-outline">{{ model.summary.accuracy_percentage }}%</div>
      </div>

      <div class="stats shadow mt-4">
        <div class="stat">
          <div class="stat-title">Total</div>
          <div class="stat-value text-primary">{{ model.summary.total }}</div>
        </div>
        <div class="stat">
          <div class="stat-title">Correct</div>
          <div class="stat-value text-secondary">{{ model.summary.corrects }}</div>
        </div>
        <div class="stat">
          <div class="stat-title">Accuracy</div>
          <div class="stat-value">{{ model.summary.accuracy_percentage }}%</div>
        </div>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mt-6">
        <ClientOnly>
          <apexchart type="bar" height="220" :options="barOptions" :series="barSeries" />
        </ClientOnly>
        <ClientOnly>
          <apexchart type="radialBar" height="220" :options="radialOptions"
            :series="[model.summary.accuracy_percentage]" />
        </ClientOnly>
      </div>

      <div class="overflow-x-auto mt-6">
        <table class="table table-zebra">
          <thead>
            <tr>
              <th>Id</th>
              <th>Ok</th>
              <th>Out</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="r in model.results.slice(0, 3)" :key="r.id">
              <td class="font-mono text-xs md:text-sm">{{ r.id }}</td>
              <td>
                <span :class="r.ok ? 'badge badge-success' : 'badge badge-error'">{{ r.ok ? '✓' : '✗' }}</span>
              </td>
              <td class="font-mono text-xs md:text-sm truncate max-w-[16rem]" :title="r.output">{{ r.output }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useDaisyColors } from '~/composables/useDaisyColors'

type BenchmarkModel = {
  model: string
  summary: { total: number; corrects: number; accuracy_percentage: number }
  results: Array<{ id: string; ok: boolean; output: string }>
}

const props = defineProps<{ model: BenchmarkModel }>()
const modelName = computed(() => props.model.model)

const { secondary, accent, baseContent, base300, primary } = useDaisyColors()

const barOptions = computed(() => ({
  chart: { toolbar: { show: false }, foreColor: baseContent(), background: 'transparent' },
  grid: { borderColor: base300() },
  theme: { mode: 'dark' },
  xaxis: { categories: ['Correct', 'Incorrect'] },
  colors: [secondary(), accent()],
  dataLabels: { enabled: false },
}))

const barSeries = computed(() => {
  const incorrect = Math.max(0, props.model.summary.total - props.model.summary.corrects)
  return [{ name: 'Count', data: [props.model.summary.corrects, incorrect] }]
})

const radialOptions = computed(() => ({
  chart: { foreColor: baseContent(), background: 'transparent' },
  plotOptions: {
    radialBar: {
      hollow: { size: '70%', margin: 10 },
      color: primary(),
      dataLabels: {
        showOn: 'always',
        name: {
          show: true,
          color: baseContent()
        },
        value: {
          formatter: (v: number) => `${v}%`,
          fontSize: '16px',
          show: true,
          color: baseContent()
        }
      }
    }
  },
  colors: [primary()],
  labels: ['Accuracy']
}))
</script>
