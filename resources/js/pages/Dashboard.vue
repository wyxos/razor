<script setup lang="ts">
import AppLayout from '@/layouts/AppLayout.vue';
import { type BreadcrumbItem } from '@/types';
import { Head } from '@inertiajs/vue3';
import PlaceholderPattern from '../components/PlaceholderPattern.vue';

const breadcrumbs: BreadcrumbItem[] = [
    {
        title: 'Dashboard',
        href: '/dashboard',
    },
];

import { ref } from 'vue';

const showUpdateModal = ref(false);
const updateOutput = ref('');
const isUpdating = ref(false);

const runUpdate = async () => {
    showUpdateModal.value = true;
    updateOutput.value = '';
    isUpdating.value = true;

    const response = await fetch('/app/update', {
        credentials: 'same-origin'
    });

    if (!response.ok) {
        updateOutput.value = `❌ Failed: ${response.status} ${response.statusText}`;
        isUpdating.value = false;
        return;
    }

    const reader = response.body?.getReader();
    if (!reader) {
        updateOutput.value = `⚠️ No readable stream available.`;
        isUpdating.value = false;
        return;
    }

    const decoder = new TextDecoder();

    while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        updateOutput.value += decoder.decode(value, { stream: true });
    }

    isUpdating.value = false;
};
</script>

<template>
    <Head title="Dashboard" />

    <AppLayout :breadcrumbs="breadcrumbs">
        <div class="flex h-full flex-1 flex-col gap-4 rounded-xl p-4">
            <button
                @click="runUpdate"
                class="self-start rounded bg-black px-4 py-2 text-white dark:bg-white dark:text-black"
            >
                Run Update
            </button>

            <!-- Update Output Modal -->
            <div
                v-if="showUpdateModal"
                class="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm"
            >
                <div class="max-w-3xl w-full rounded-lg bg-white p-4 shadow dark:bg-neutral-900">
                    <h2 class="mb-2 text-lg font-medium text-gray-900 dark:text-gray-100">Running Update</h2>
                    <pre id="update-output" class="overflow-y-auto max-h-[400px]">{{ updateOutput }}</pre>
                    <div class="mt-4 text-right">
                        <button
                            @click="showUpdateModal = false"
                            class="rounded border px-4 py-2 text-sm"
                            :disabled="isUpdating"
                        >
                            {{ isUpdating ? 'Running...' : 'Close' }}
                        </button>
                    </div>
                </div>
            </div>

            <div class="grid auto-rows-min gap-4 md:grid-cols-3">
                <div class="relative aspect-video overflow-hidden rounded-xl border border-sidebar-border/70 dark:border-sidebar-border">
                    <PlaceholderPattern />

                </div>
                <div class="relative aspect-video overflow-hidden rounded-xl border border-sidebar-border/70 dark:border-sidebar-border">
                    <PlaceholderPattern />
                </div>
                <div class="relative aspect-video overflow-hidden rounded-xl border border-sidebar-border/70 dark:border-sidebar-border">
                    <PlaceholderPattern />
                </div>
            </div>
            <div class="relative min-h-[100vh] flex-1 rounded-xl border border-sidebar-border/70 dark:border-sidebar-border md:min-h-min">
                <PlaceholderPattern />
            </div>
        </div>
    </AppLayout>
</template>
