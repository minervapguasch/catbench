<template>
  <header class="navbar bg-base-100 shadow-sm rounded-box mt-2">
    <div class="flex-1 min-w-0">
      <div class="flex items-center gap-3 min-w-0">
        <div class="avatar placeholder">
          <div class="bg-primary text-primary-content rounded-full w-8">
            <img src="/catbench.jpg" alt="CatBench" class="w-full h-full object-contain" />
          </div>
        </div>
        <div class="min-w-0">
          <h1 class="text-xl font-semibold truncate">{{ title }}</h1>
          <p class="text-sm opacity-70 truncate">{{ subtitle }}</p>
        </div>
      </div>
    </div>
    <div class="flex-none gap-2 items-center flex">
      <div class="hidden md:flex items-center gap-2">
        <div v-if="generatedAt" class="badge badge-outline">{{ generatedAt }}</div>
        <div v-if="totalModels !== undefined" class="badge badge-outline">{{ totalModels }} models</div>
      </div>
      <a class="btn btn-sm btn-primary" :href="repoUrl" target="_blank" rel="noopener">GitHub</a>
    </div>
  </header>

  <div class="mt-4">
    <div role="tablist" class="tabs tabs-boxed bg-base-200">
      <button role="tab" class="tab" :class="{ 'tab-active': modelValue==='accuracy' }" @click="$emit('update:modelValue','accuracy')">Accuracy</button>
      <button role="tab" class="tab" :class="{ 'tab-active': modelValue==='cost' }" @click="$emit('update:modelValue','cost')">Cost</button>
      <button role="tab" class="tab" :class="{ 'tab-active': modelValue==='speed' }" @click="$emit('update:modelValue','speed')">Speed</button>
      <button role="tab" class="tab" :class="{ 'tab-active': modelValue==='combined' }" @click="$emit('update:modelValue','combined')">Combined</button>
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{ 
  title: string
  subtitle?: string
  repoUrl: string
  generatedAt?: string
  totalModels?: number
  modelValue?: 'accuracy' | 'cost' | 'speed' | 'combined'
}>()
</script>


