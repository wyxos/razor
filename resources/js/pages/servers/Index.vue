<script setup lang="ts">
import AppLayout from '@/layouts/AppLayout.vue';
import { type BreadcrumbItem } from '@/types';
import { Head } from '@inertiajs/vue3';
import PlaceholderPattern from '../../components/PlaceholderPattern.vue';
import { router } from '@inertiajs/vue3';
import { Button } from '@/components/ui/button';
import { OTable, OTableColumn } from '@oruga-ui/oruga-next';

const breadcrumbs: BreadcrumbItem[] = [
    {
        title: 'Dashboard',
        href: '/dashboard',
    },
];

defineProps({
    servers: {
        type: Object,
        required: true,
    }
});
</script>

<template>
    <Head title="Dashboard" />

    <AppLayout :breadcrumbs="breadcrumbs">
        <div class="p-4">
            <Button @click="router.visit('/servers/create')">Create Server</Button>

            <OTable :data="servers.data" pagination :per-page="servers.per_page" :total="servers.total">
                <OTableColumn v-slot="{row}">
                    {{ row.id }}
                </OTableColumn>
                <OTableColumn v-slot="{row}">
                    {{ row.label }}
                </OTableColumn>
                <OTableColumn v-slot="{row}">
                    {{ row.ip }}
                </OTableColumn>
                <OTableColumn v-slot="{row}">
                    <Button @click="router.visit(route('servers.show', row.id))">Edit</Button>
                </OTableColumn>
            </OTable>
        </div>
    </AppLayout>
</template>
