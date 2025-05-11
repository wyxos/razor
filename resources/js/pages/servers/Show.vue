<script setup lang="ts">
import AppLayout from '@/layouts/AppLayout.vue';
import { type BreadcrumbItem } from '@/types';
import { Head, useForm } from '@inertiajs/vue3';
import PlaceholderPattern from '../../components/PlaceholderPattern.vue';
import { router } from '@inertiajs/vue3';
import { Button } from '@/components/ui/button';
import { ref } from 'vue';

const breadcrumbs: BreadcrumbItem[] = [
    {
        title: 'Dashboard',
        href: '/dashboard',
    },
    {
        title: 'Servers',
        href: '/servers',
    },
];

const props = defineProps({
    server: Object,
});

const form = useForm({
    label: props.server.label,
});

const editMode = ref(false);
const showDeleteConfirm = ref(false);

const submitEdit = () => {
    form.patch(`/servers/${props.server.id}`);
    editMode.value = false;
};

const deleteServer = () => {
    router.delete(`/servers/${props.server.id}`);
};
</script>

<template>
    <Head :title="server.label" />

    <AppLayout :breadcrumbs="breadcrumbs">
        <div class="space-y-6 p-4">
            <div class="flex items-center justify-between">
                <div v-if="!editMode" class="flex items-center space-x-4">
                    <h2 class="text-2xl font-bold">{{ server.label }}</h2>
                    <Button variant="outline" size="sm" @click="editMode = true">Edit</Button>
                </div>
                <form v-else @submit.prevent="submitEdit" class="flex items-center space-x-2">
                    <Input v-model="form.label" />
                    <Button type="submit" size="sm">Save</Button>
                    <Button type="button" variant="outline" size="sm" @click="editMode = false">Cancel</Button>
                </form>
                <Button variant="destructive" size="sm" @click="showDeleteConfirm = true">Delete Server</Button>
            </div>

            <div class="grid grid-cols-2 gap-4">
                <div>
                    <div class="text-sm text-gray-500">IP Address</div>
                    <div>{{ server.ip || 'N/A' }}</div>
                </div>
                <div>
                    <div class="text-sm text-gray-500">Type</div>
                    <div>{{ server.external ? 'External' : 'Internal' }}</div>
                </div>
                <div>
                    <div class="text-sm text-gray-500">Created</div>
                    <div>{{ new Date(server.created_at).toLocaleDateString() }}</div>
                </div>
                <div>
                    <div class="text-sm text-gray-500">Last Updated</div>
                    <div>{{ new Date(server.updated_at).toLocaleDateString() }}</div>
                </div>
            </div>

            <div v-if="showDeleteConfirm" class="bg-opacity-50 fixed inset-0 flex items-center justify-center bg-black">
                <div class="rounded-lg bg-white p-6">
                    <h3 class="mb-4 text-lg font-semibold">Confirm Delete</h3>
                    <p class="mb-4">Are you sure you want to delete this server?</p>
                    <div class="flex justify-end space-x-2">
                        <Button variant="outline" @click="showDeleteConfirm = false">Cancel</Button>
                        <Button variant="destructive" @click="deleteServer">Delete</Button>
                    </div>
                </div>
            </div>
        </div>
    </AppLayout>
</template>
