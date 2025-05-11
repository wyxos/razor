<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>@yield('title')</title>

        @vite('resources/css/app.css')
    </head>
    <body class="antialiased">
        <div class="relative flex items-top justify-center min-h-screen bg-gray-100 dark:bg-gray-900 sm:items-center sm:pt-0">
            <div class="max-w-xl mx-auto sm:px-6 lg:px-8">
                <div class="flex flex-col gap-4">
                    <div class="flex items-center pt-8 sm:justify-start sm:pt-0">
                        <div class="px-4 text-lg text-gray-500 border-r border-gray-400 tracking-wider">
                            @yield('code')
                        </div>

                        <div class="ml-4 text-lg text-gray-500 uppercase tracking-wider">
                            @yield('message')
                        </div>
                    </div>
                    <div class="mt-6 text-center">
                        @auth
                            <a href="{{ route('dashboard') }}"
                               class="inline-block px-4 py-2 border border-gray-300 rounded-md text-sm text-gray-700 bg-white hover:bg-gray-100 dark:bg-gray-800 dark:border-gray-600 dark:text-gray-200 dark:hover:bg-gray-700">
                                Go to Dashboard
                            </a>
                        @else
                            <a href="{{ url('/') }}"
                               class="inline-block px-4 py-2 border border-gray-300 rounded-md text-sm text-gray-700 bg-white hover:bg-gray-100 dark:bg-gray-800 dark:border-gray-600 dark:text-gray-200 dark:hover:bg-gray-700">
                                Back to Home
                            </a>
                        @endauth
                    </div>

                </div>
            </div>
        </div>
    </body>
</html>
