<script setup lang="ts">
import AppLayout from '@/layouts/AppLayout.vue';
import { type BreadcrumbItem } from '@/types';
import { Head, router } from '@inertiajs/vue3';
import PlaceholderPattern from '../../components/PlaceholderPattern.vue';
import { Button } from '@/components/ui/button';
import { OTable, OTableColumn } from '@oruga-ui/oruga-next';

const breadcrumbs: BreadcrumbItem[] = [
    {
        title: 'Dashboard',
        href: '/dashboard',
    },
];

defineProps({
    server: {
        type: Object,
        required: true,
    },
    applications: {
        type: Object,
        required: true,
    },
});
</script>

<template>
    <Head title="Dashboard" />

    <AppLayout :breadcrumbs="breadcrumbs">
        <div class="flex h-full flex-1 flex-col gap-4 rounded-xl p-4">
            <Button @click="router.visit('/applications/create')">Create Application</Button>

            <OTable :data="applications.data" pagination :per-page="applications.per_page" :total="applications.total">
                <OTableColumn v-slot="{ row }">
                    {{ row.id }}
                </OTableColumn>
                <OTableColumn v-slot="{ row }">
                    {{ row.name }}
                </OTableColumn>
                <OTableColumn v-slot="{ row }">
                    <Button @click="router.visit(route('applications.show', row.id))">Edit</Button>
                </OTableColumn>

                <template #empty>
                    <p>No applications found.</p>
                </template>
            </OTable>
        </div>
    </AppLayout>
</template>
