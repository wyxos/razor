<script setup lang="ts">
import AppLayout from '@/layouts/AppLayout.vue';
import { type BreadcrumbItem } from '@/types';
import { Head, useForm } from '@inertiajs/vue3';
import PlaceholderPattern from '../../components/PlaceholderPattern.vue';
import { router } from '@inertiajs/vue3';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import InputError from '@/components/InputError.vue';
import { ref } from 'vue';

const breadcrumbs: BreadcrumbItem[] = [
    {
        title: 'Dashboard',
        href: '/dashboard',
    },
];

const form = useForm({
    label: '',
    ip: '',
    external: true,
});

const submit = () => {
    form.post('/servers');
};
</script>

<template>
    <Head title="Dashboard" />

    <AppLayout :breadcrumbs="breadcrumbs">
        <div class="flex h-full flex-1 flex-col gap-4 rounded-xl p-4">
            <form @submit.prevent="submit" class="space-y-4">
                <div class="grid gap-2">
                    <Label for="label">Label</Label>
                    <Input id="label" type="text" v-model="form.label" class="mt-1 block w-full" required />
                    <InputError :message="form.errors.label" />
                </div>

                <div>
                    <label class="flex items-center space-x-2">
                        <input
                            type="checkbox"
                            v-model="form.external"
                            class="rounded border-gray-300 text-indigo-600 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                        />
                        <span class="text-sm font-medium text-gray-700">External server</span>
                    </label>
                </div>

                <div class="grid gap-2">
                    <Label for="ip">IP Address</Label>
                    <Input id="ip" type="text" v-model="form.ip" class="mt-1 block w-full" :disabled="!form.external" required />
                    <InputError :message="form.errors.ip" />
                </div>

                <Button type="submit">Create Server</Button>
            </form>
        </div>
    </AppLayout>
</template>
