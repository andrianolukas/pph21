<script setup lang="ts">
import { Link } from '@inertiajs/vue3';
import { FileText, Calculator, Menu, X } from '@lucide/vue';
import { ref } from 'vue';
import { useCurrentUrl } from '@/composables/useCurrentUrl';

const { isCurrentUrl } = useCurrentUrl();
const mobileOpen = ref(false);

const navItems = [
    { title: 'Profil CV', href: '/', icon: FileText },
    { title: 'PPh 21', href: '/pph21', icon: Calculator },
];
</script>

<template>
    <div class="flex min-h-screen bg-[#f5f7f4]">
        <!-- Desktop sidebar -->
        <aside
            class="hidden lg:fixed lg:inset-y-0 lg:left-0 lg:z-30 lg:flex lg:w-52 lg:flex-col"
        >
            <div
                class="flex grow flex-col gap-y-6 overflow-y-auto border-r border-[#dce8df] bg-white px-4 py-6"
            >
                <div
                    class="text-xs font-semibold tracking-[0.16em] text-[#1f7a55] uppercase"
                >
                    Menu
                </div>
                <nav class="flex flex-col gap-1">
                    <Link
                        v-for="item in navItems"
                        :key="item.href"
                        :href="item.href"
                        class="flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition-colors"
                        :class="
                            isCurrentUrl(item.href)
                                ? 'bg-[#dff2e7] text-[#1f7a55]'
                                : 'text-[#526158] hover:bg-[#f3f7f4]'
                        "
                    >
                        <component
                            :is="item.icon"
                            :size="18"
                            :stroke-width="1.8"
                        />
                        {{ item.title }}
                    </Link>
                </nav>
            </div>
        </aside>

        <!-- Mobile header -->
        <div
            class="fixed inset-x-0 top-0 z-40 flex h-14 items-center border-b border-[#dce8df] bg-white px-4 lg:hidden"
        >
            <button
                type="button"
                class="p-1.5 text-[#526158] hover:text-[#1f7a55]"
                @click="mobileOpen = !mobileOpen"
            >
                <X v-if="mobileOpen" :size="20" />
                <Menu v-else :size="20" />
            </button>
            <span
                class="ml-3 text-sm font-semibold tracking-[0.12em] text-[#1f7a55] uppercase"
                >Menu</span
            >
        </div>

        <!-- Mobile overlay -->
        <Transition name="fade">
            <div
                v-if="mobileOpen"
                class="fixed inset-0 z-30 bg-black/30 lg:hidden"
                @click="mobileOpen = false"
            />
        </Transition>

        <!-- Mobile sidebar -->
        <Transition name="slide">
            <aside
                v-if="mobileOpen"
                class="fixed inset-y-0 left-0 z-40 w-56 border-r border-[#dce8df] bg-white px-4 py-6 lg:hidden"
            >
                <nav class="flex flex-col gap-1">
                    <Link
                        v-for="item in navItems"
                        :key="item.href"
                        :href="item.href"
                        class="flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition-colors"
                        :class="
                            isCurrentUrl(item.href)
                                ? 'bg-[#dff2e7] text-[#1f7a55]'
                                : 'text-[#526158] hover:bg-[#f3f7f4]'
                        "
                        @click="mobileOpen = false"
                    >
                        <component
                            :is="item.icon"
                            :size="18"
                            :stroke-width="1.8"
                        />
                        {{ item.title }}
                    </Link>
                </nav>
            </aside>
        </Transition>

        <!-- Main content -->
        <main class="flex-1 pt-14 lg:ml-52 lg:pt-0">
            <slot />
        </main>
    </div>
</template>

<style scoped>
.fade-enter-active,
.fade-leave-active {
    transition: opacity 0.2s ease;
}
.fade-enter-from,
.fade-leave-to {
    opacity: 0;
}

.slide-enter-active,
.slide-leave-active {
    transition: transform 0.2s ease;
}
.slide-enter-from,
.slide-leave-to {
    transform: translateX(-100%);
}
</style>
