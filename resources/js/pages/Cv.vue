<script setup lang="ts">
import { Head } from '@inertiajs/vue3';

const experiences = [
    {
        company: 'PT. TERANG NUSANTARA SENTOSA',
        location: 'Kab Tangerang, Indonesia',
        role: 'Tax Konsultan / Tax Administration',
        period: 'Mei 2025 – Juli 2026',
        tasks: [
            'Penyusunan laporan keuangan fiskal',
            'Administrasi perpajakan (SPT PPN, PPh 21, PPh 23, PPh Final)',
            'Rekonsiliasi pajak dan pengelolaan dokumen perpajakan',
            'Pengisian SPT Unifikasi dan Faktur Pajak',
            'Penggunaan software perpajakan seperti Coretax',
        ],
    },
    {
        company: 'PT. CENTRA NUSA INDONESIA',
        location: 'Surabaya, Indonesia',
        role: 'IT Staff / Generalist Staff',
        period: 'April 2021 – Maret 2025',
        tasks: [
            'Pengelolaan infrastruktur IT perusahaan',
            'Administrasi sistem Active Directory dan Mail Server',
            'Pengelolaan server virtualisasi (Proxmox, Citrix, VirtualBox)',
            'Pengelolaan jaringan LAN/WiFi, Mikrotik, CCTV, PABX',
            'Support operasional umum dan administrasi perusahaan',
            'Pengadaan barang dan pengelolaan vendor',
        ],
    },
    {
        company: 'PT. AIRMAS INTERNATIONAL',
        location: 'Surabaya, Indonesia',
        role: 'IT Staff',
        period: 'Juli 2017 – Oktober 2019',
        tasks: [
            'Pengelolaan infrastruktur IT dan jaringan',
            'Pengelolaan server dan sistem operasi Windows/Linux',
            'Troubleshooting hardware dan software',
            'Pengelolaan sistem email dan Active Directory',
        ],
    },
    {
        company: 'PT. DUTA CIPTA KONSULTAMA',
        location: 'Surabaya, Indonesia',
        role: 'Network Architect and Infrastructure',
        period: 'Oktober 2013 – Desember 2016',
        tasks: [
            'Perancangan dan implementasi infrastruktur jaringan',
            'Pengelolaan server dan sistem operasi Windows/Linux',
            'Pengelolaan jaringan LAN/WiFi, Mikrotik, CCTV',
            'Pengelolaan server virtualisasi (VirtualBox, Proxmox)',
            'Troubleshooting jaringan dan infrastruktur IT',
        ],
    },
];
</script>

<template>
    <Head title="CV Saya" />

    <div class="min-h-screen bg-[#f5f7f4] py-6 lg:py-10">
        <div class="mx-auto max-w-[800px] bg-white px-6 py-8 shadow-sm sm:px-10 sm:py-10 lg:px-14 lg:py-12">

            <!-- Header -->
            <header class="flex items-start justify-between gap-6">
                <div class="min-w-0 flex-1">
                    <h1 class="text-2xl font-bold tracking-tight text-[#17231d] sm:text-3xl lg:text-[2rem]">ANDRIANO LUKAS HAHYARY S.KOM</h1>
                    <p class="mt-2 text-base font-semibold tracking-wide text-[#1f7a55] sm:text-lg lg:text-xl">TAX ACCOUNTING &amp; TAX ADMINISTRATION</p>
                    <div class="mt-3 flex flex-col gap-1 text-sm text-[#526158]">
                        <span>Bandung | 08988076787 | andrianolukashahyary@gmail.com</span>
                        <span>IG: @andrianolukas</span>
                    </div>
                </div>
                <img
                    src="/image/profil.png"
                    alt="Foto Profil Andriano Lukas"
                    class="h-28 w-28 shrink-0 rounded-lg object-cover sm:h-32 sm:w-32 lg:h-36 lg:w-36"
                />
            </header>

            <!-- Ringkasan -->
            <section class="mt-8">
                <h2 class="text-base font-bold uppercase tracking-wide text-[#17231d] sm:text-lg">Ringkasan</h2>
                <hr class="mt-2 border-[#dce8df]" />
                <p class="mt-3 text-sm leading-relaxed text-[#3a4a3f] sm:text-[0.9rem]">
                    Bepengalaman lebih dari 2 tahun di bidang Tax Accounting dan Tax Administration, didukung pengalaman dalam Finance Support dan administrasi operasional perusahaan, dengan uraian pekerjaan seperti penyusunan laporan keuangan fiskal, administrasi perpajakan, rekonsiliasi pajak, serta pengelolaan dokumen perpajakan. Memiliki kemampuan analitis, teliti, adaptif, dan mampu bekerja secara efektif baik secara mandiri maupun dalam tim. Saya saat ini sedang mengikuti Pelatihan Brevet AB di IAI dan akan selesai awal September 2026.
                </p>
            </section>

            <!-- Pengalaman -->
            <section class="mt-7">
                <h2 class="text-base font-bold uppercase tracking-wide text-[#17231d] sm:text-lg">Pengalaman</h2>
                <hr class="mt-2 border-[#dce8df]" />

                <div v-for="(exp, idx) in experiences" :key="idx" :class="idx > 0 ? 'mt-5' : 'mt-4'">
                    <div class="flex flex-wrap items-baseline justify-between gap-x-3 gap-y-1">
                        <h3 class="text-sm font-bold text-[#17231d] sm:text-[0.9rem]">{{ exp.company }}</h3>
                        <span class="text-xs text-[#718078] sm:text-sm">{{ exp.location }}</span>
                    </div>
                    <p class="mt-0.5 text-sm font-medium text-[#3a4a3f] sm:text-[0.9rem]">{{ exp.role }}</p>
                    <p class="mt-0.5 text-xs text-[#718078] sm:text-sm">{{ exp.period }}</p>
                    <ul class="mt-2 list-inside list-disc space-y-1 pl-1 text-sm text-[#3a4a3f] sm:text-[0.9rem]">
                        <li v-for="(task, tIdx) in exp.tasks" :key="tIdx">{{ task }}</li>
                    </ul>
                </div>
            </section>

            <!-- Pendidikan -->
            <section class="mt-7">
                <h2 class="text-base font-bold uppercase tracking-wide text-[#17231d] sm:text-lg">Pendidikan</h2>
                <hr class="mt-2 border-[#dce8df]" />

                <div class="mt-4">
                    <h3 class="text-sm font-bold text-[#17231d] sm:text-[0.9rem]">UNIVERSITAS BHAYANGKARA SURABAYA <span class="font-normal text-[#718078]">(2014 – 2022)</span></h3>
                    <p class="mt-0.5 text-sm text-[#3a4a3f] sm:text-[0.9rem]">S.KOM dan Teknik Informatika – IPK 3.21</p>
                </div>

                <div class="mt-4">
                    <h3 class="text-sm font-bold text-[#17231d] sm:text-[0.9rem]">SMKN 3 BUDURAN - SIDOARJO <span class="font-normal text-[#718078]">(2010 – 2013)</span></h3>
                    <p class="mt-0.5 text-sm text-[#3a4a3f] sm:text-[0.9rem]">Teknik Komputer dan Jaringan</p>
                </div>
            </section>

            <!-- Kemampuan -->
            <section class="mt-7">
                <h2 class="text-base font-bold uppercase tracking-wide text-[#17231d] sm:text-lg">Kemampuan</h2>
                <hr class="mt-2 border-[#dce8df]" />

                <div class="mt-4 space-y-3 text-sm text-[#3a4a3f] sm:text-[0.9rem]">
                    <div>
                        <span class="font-semibold">Tax &amp; Accounting:</span>
                        Jurnal Kas/Bank, SPT PPN, PPh 21, Bukti Potong PPh 23, PPh Final Pasal 4(2), SPT Unifikasi, Faktur Pajak. (On progress Brevet A B IAI), Tools: Accurate, MYOB, Coretax.
                    </div>
                    <div>
                        <span class="font-semibold">General Affair:</span>
                        Pengadaan barang, pengelolaan fasilitas, vendor, logistik, payroll absensi.
                    </div>
                    <div>
                        <span class="font-semibold">IT:</span>
                        Active Directory, Mail Server, Proxmox, Citrix, VirtualBox, Mikrotik, LAN/WiFi, CCTV, PABX, Windows, Linux, troubleshooting.
                    </div>
                </div>
            </section>

        </div>
    </div>
</template>
