<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3'
</script>

<template>
    <Head title="Razor Panel" />

    <div class="min-h-screen flex flex-col items-center justify-center bg-white dark:bg-neutral-900 text-gray-800 dark:text-gray-100 px-4">
        <h1 class="text-4xl font-semibold mb-4">Welcome to Razor</h1>
        <p class="text-center text-sm text-gray-600 dark:text-gray-400 mb-8 max-w-md">
            Razor is your self-hosted server panel — manage PHP apps, workers, crons, SSL and more from one place.
        </p>

        <div class="flex gap-4">
            <Link
                :href="route('login')"
                class="px-4 py-2 rounded border border-gray-300 dark:border-neutral-700 hover:bg-gray-100 dark:hover:bg-neutral-800 transition"
            >
                Log in
            </Link>
            <Link
                :href="route('register')"
                class="px-4 py-2 rounded bg-black text-white dark:bg-white dark:text-black hover:opacity-90 transition"
            >
                Register
            </Link>
        </div>
    </div>
</template>
