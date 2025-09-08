<template>
    <div class="min-h-svh flex flex-col">
        <div class="container mx-auto p-4 space-y-6">
            <BenchHeader
                title="CatBench"
                subtitle="Catalan Linguistic Benchmarks"
                :repo-url="repoUrl"
                :generated-at="formattedDate"
                :total-models="models.length"
                v-model="activeTab"
            />

            <component :is="currentChart" :models="models" />

            <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6" v-if="activeTab==='accuracy'">
                <ModelCard v-for="m in models" :key="m.model" :model="m" />
            </div>
        </div>
    </div>
  </template>

  <script setup lang="ts">
  import results from '~/static/results.json'
  import BenchHeader from '~/components/BenchHeader.vue'
  import ModelCard from '~/components/ModelCard.vue'
  import AccuracyByModelChart from '~/components/AccuracyByModelChart.vue'
  import CostByModelChart from '~/components/CostByModelChart.vue'
  import SpeedByModelChart from '~/components/SpeedByModelChart.vue'
  import CombinedCostAccuracyChart from '~/components/CombinedCostAccuracyChart.vue'

  type BenchmarkModel = {
    model: string
    summary: { total: number; corrects: number; accuracy_percentage: number }
    results: Array<{ id: string; ok: boolean; output: string; meta?: Record<string, any> }>
  }

  type ResultsPayload = { generated_at: string; models: BenchmarkModel[] }
  // const { data } = await useFetch<ResultsPayload>('/results.json');
  const data = ref<ResultsPayload>(results as any);

  const models = computed<BenchmarkModel[]>(() => (data.value?.models ?? []))
  const formattedDate = computed(() => {
    const d = data.value?.generated_at
    return d ? new Date(d).toLocaleString() : ''
  })

  const repoUrl = 'https://github.com/MinervaDS/minerva'

  const activeTab = ref<'accuracy' | 'cost' | 'speed' | 'combined'>('accuracy')
  const currentChart = computed(() => {
    switch (activeTab.value) {
      case 'cost': return CostByModelChart
      case 'speed': return SpeedByModelChart
      case 'combined': return CombinedCostAccuracyChart
      default: return AccuracyByModelChart
    }
  });

  useHead({
    title: 'CatBench',
    meta: [
      { name: 'description', content: 'CatBench is a benchmark for Catalan language models' }
    ]
  })
  </script>

  <style scoped>
  .container { max-width: 1200px; }
  </style>