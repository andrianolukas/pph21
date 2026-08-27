<script setup lang="ts">
import { Head } from '@inertiajs/vue3';
import { Calculator, RotateCcw, Wallet } from '@lucide/vue';
import { computed, nextTick, reactive, ref } from 'vue';

type PtkpStatus = '' | 'TK0' | 'K0' | 'K1' | 'K2' | 'K3';
type AmountField = 'salary' | 'positionAllowance' | 'mealAllowance' | 'transportAllowance' | 'holidayBonus' | 'bonus' | 'officialVehicle' | 'jkk' | 'jkm' | 'bpjsInsurance' | 'zakat' | 'employeeJht' | 'taxCredit' | 'totalMonths';

const incomeFields: { key: AmountField; label: string; required?: boolean }[] = [
    { key: 'salary', label: 'Gaji', required: true },
    { key: 'positionAllowance', label: 'TJ Jab' },
    { key: 'mealAllowance', label: 'TJ Makan' },
    { key: 'transportAllowance', label: 'TJ Trans' },
    { key: 'holidayBonus', label: 'B. Idul Fitri' },
    { key: 'bonus', label: 'Bonus' },
    { key: 'officialVehicle', label: 'Kend Dinas' },
    { key: 'jkk', label: 'JKK dit Pers' },
    { key: 'jkm', label: 'JKM dit Pers' },
    { key: 'bpjsInsurance', label: 'Ass BPJS dit Pers' },
];

const form = reactive<Record<AmountField, number | ''> & { ptkpStatus: PtkpStatus }>({
    salary: '',
    positionAllowance: 0,
    mealAllowance: 0,
    transportAllowance: 0,
    holidayBonus: 0,
    bonus: 0,
    officialVehicle: 0,
    jkk: 0,
    jkm: 0,
    bpjsInsurance: 0,
    zakat: 0,
    employeeJht: 0,
    taxCredit: 0,
    totalMonths: 1,
    ptkpStatus: '',
});

const errors = reactive<Record<string, string>>({});
const ptkpValues: Record<Exclude<PtkpStatus, ''>, number> = {
    TK0: 54_000_000,
    K0: 58_500_000,
    K1: 63_000_000,
    K2: 67_500_000,
    K3: 72_000_000,
};

const amount = (field: AmountField) => (typeof form[field] === 'number' && Number.isFinite(form[field]) ? form[field] : 0);
const totalGross = computed(() => incomeFields.reduce((total, field) => total + amount(field.key), 0));
const positionExpense = computed(() => {
    const months = Math.min(
        Math.max(Number(form.totalMonths) || 1, 1),
        12,
    );

    return Math.min(
        totalGross.value * 0.05,
        months * 500_000,
    );
});
const totalDeductions = computed(() => positionExpense.value + amount('zakat') + amount('employeeJht'));
const netIncome = computed(() => Math.max(0, totalGross.value - totalDeductions.value));

const previousNetIncome = ref<number | ''>('');

const previousNetIncomeAmount = computed(() => {
    const v = previousNetIncome.value;

    return typeof v === 'number' && Number.isFinite(v) ? v : 0;
});

const totalNetIncome = computed(() => netIncome.value + previousNetIncomeAmount.value);

const isAnnualized = ref(false);
const annualizedMonths = ref(12);

const annualizedNetIncome = computed(() => {
    const months = Math.min(Math.max(Number(annualizedMonths.value) || 1, 1), 12);

    return Math.round((12 / months) * totalNetIncome.value);
});

const taxableNetIncome = computed(() => {
    if (isAnnualized.value) {
        return annualizedNetIncome.value;
    }

    return totalNetIncome.value;
});

const ptkp = computed(() => form.ptkpStatus ? ptkpValues[form.ptkpStatus] : 0);

const taxableIncome = computed(() =>
    Math.floor(Math.max(0, taxableNetIncome.value - ptkp.value) / 1000) * 1000
);
//const taxableIncome = computed(() => Math.max(0, taxableNetIncome.value - ptkp.value));

const taxLayers = computed(() => {
    const layers = [
        { label: '5% x Rp60.000.000', rate: 0.05, limit: 60_000_000 },
        { label: '15% x Rp190.000.000', rate: 0.15, limit: 190_000_000 },
        { label: '25% x sisa PKP', rate: 0.25, limit: Number.POSITIVE_INFINITY },
    ];
    let remaining = taxableIncome.value;

    return layers.map((layer) => {
        const taxable = Math.min(Math.max(remaining, 0), layer.limit);
        remaining -= taxable;

        return { ...layer, taxable, tax: taxable * layer.rate };
    }).filter((layer) => layer.taxable > 0);
});

const taxDue = computed(() => taxLayers.value.reduce((total, layer) => total + layer.tax, 0));

const effectiveTaxDue = computed(() => {
    if (!isAnnualized.value) {
        return taxDue.value;
    }

    const months = Math.min(
        Math.max(Number(annualizedMonths.value) || 1, 1),
        12,
    );

    return Math.round((months / 12) * taxDue.value);
});

const taxCredit = computed(() => amount('taxCredit'));
const remainingTax = computed(() => Math.max(0, effectiveTaxDue.value - taxCredit.value));
const overpayment = computed(() => Math.max(0, taxCredit.value - effectiveTaxDue.value));

const formatRupiah = (value: number) => new Intl.NumberFormat('id-ID', {
    style: 'currency',
    currency: 'IDR',
    maximumFractionDigits: 0,
}).format(value);

const validate = () => {
    Object.keys(errors).forEach((key) => delete errors[key]);

    if (form.salary === '' || amount('salary') < 0) {
        errors.salary = 'Gaji wajib diisi dan tidak boleh kurang dari 0.';
    }

    if (!form.ptkpStatus) {
        errors.ptkpStatus = 'Status PTKP wajib dipilih.';
    }

    return Object.keys(errors).length === 0;
};

const handleSubmit = () => validate();
const clearError = (field: string) => {
    delete errors[field];
};

const normalizeAmount = (field: AmountField) => {
    if (typeof form[field] === 'number' && form[field] < 0) {
        form[field] = 0;
    }

    clearError(field);
};

const formatDisplay = (value: number | ''): string => {
    if (value === '') {
        return '';
    }

    return new Intl.NumberFormat('id-ID').format(value);
};

const parseInput = (raw: string): number | '' => {
    const digits = raw.replace(/[^0-9]/g, '');

    return digits === '' ? '' : parseInt(digits, 10);
};

const handleAmountInput = (field: AmountField, event: Event) => {
    const target = event.target as HTMLInputElement;
    const cursorPos = target.selectionStart ?? target.value.length;
    const oldValue = formatDisplay(form[field]);

    form[field] = parseInput(target.value);

    nextTick(() => {
        const newValue = formatDisplay(form[field]);
        const addedChars = newValue.length - oldValue.length;
        const newPos = Math.min(cursorPos + addedChars, newValue.length);
        target.setSelectionRange(newPos, newPos);
    });
};

const handlePreviousNetIncomeInput = (event: Event) => {
    const target = event.target as HTMLInputElement;
    const cursorPos = target.selectionStart ?? target.value.length;
    const oldValue = formatDisplay(previousNetIncome.value);

    previousNetIncome.value = parseInput(target.value);

    nextTick(() => {
        const newValue = formatDisplay(previousNetIncome.value);
        const addedChars = newValue.length - oldValue.length;
        const newPos = Math.min(cursorPos + addedChars, newValue.length);
        target.setSelectionRange(newPos, newPos);
    });
};

const resetForm = () => {
    incomeFields.forEach((field) => {
        form[field.key] = field.key === 'salary' ? '' : 0;
    });

    form.zakat = 0;
    form.employeeJht = 0;
    form.taxCredit = 0;
    form.totalMonths = 1;
    form.ptkpStatus = '';
    previousNetIncome.value = '';
    isAnnualized.value = false;
    annualizedMonths.value = 12;
    Object.keys(errors).forEach((key) => delete errors[key]);
};
</script>

<template>
    <Head title="Kalkulator PPh 21" />
    <main class="min-h-screen bg-[#f5f7f4] text-[#17231d]" style="color-scheme: light">
        <div class="mx-auto max-w-6xl px-4 py-6 sm:px-6 sm:py-8 lg:px-10 lg:py-12">
            <header class="mb-6 flex items-start justify-between gap-4 sm:mb-8 lg:mb-12">
                <div>
                    <div class="mb-4 flex items-center gap-3 text-[#1f7a55]">
                        <span class="flex size-9 items-center justify-center rounded-xl bg-[#dff2e7] sm:size-10"><Calculator :size="20" :stroke-width="1.8" /></span>
                        <span class="text-xs font-semibold tracking-[0.16em] uppercase sm:text-sm">PPh 21</span>
                    </div>
                    <h1 class="text-2xl font-semibold tracking-tight sm:text-3xl lg:text-5xl">Kalkulator PPh 21</h1>
                    <p class="mt-2 text-sm text-[#647169] sm:text-base lg:text-lg">Perhitungan Penghasilan Bruto</p>
                </div>
                <div class="hidden rounded-full border border-[#dbe7df] bg-white px-4 py-2 text-xs font-medium text-[#647169] sm:block">Real-time</div>
            </header>

            <form class="grid gap-5 lg:grid-cols-[minmax(0,1.2fr)_minmax(320px,0.8fr)] lg:gap-6" @submit.prevent="handleSubmit" novalidate>
                <section class="min-w-0 rounded-2xl border border-[#dce8df] bg-white p-4 shadow-[0_18px_45px_rgba(30,68,45,0.06)] sm:p-6 lg:p-8" aria-labelledby="income-title">
                    <div class="mb-5 sm:mb-7">
                        <h2 id="income-title" class="text-lg font-semibold sm:text-xl">Penghasilan</h2>
                        <p class="mt-1 text-xs text-[#718078] sm:text-sm">Masukkan seluruh penghasilan yang diterima.</p>
                    </div>
                    <div class="grid gap-3 sm:grid-cols-2 sm:gap-4 lg:gap-5">
                        <div v-for="field in incomeFields" :key="field.key">
                            <label :for="field.key" class="mb-1.5 block text-xs font-medium sm:mb-2 sm:text-sm">{{ field.label }} <span v-if="field.required" class="text-[#d34b3e]">*</span></label>
                            <div class="relative">
                                <span class="pointer-events-none absolute inset-y-0 left-3 flex items-center text-xs text-[#88958c] sm:left-4 sm:text-sm">Rp</span>
                                <input :id="field.key" :value="formatDisplay(form[field.key])" type="text" inputmode="numeric" placeholder="0" :aria-invalid="!!errors[field.key]" class="h-10 w-full rounded-xl border border-[#d6e2d9] bg-[#fbfcfb] pl-10 pr-3 text-sm outline-none transition focus:border-[#2d9468] focus:ring-3 focus:ring-[#2d9468]/15 aria-[invalid=true]:border-[#d34b3e] sm:h-11 sm:pl-12 sm:text-base" @input="handleAmountInput(field.key, $event)" />
                            </div>
                            <p v-if="errors[field.key]" class="mt-1.5 text-xs text-[#c44135] sm:mt-2 sm:text-sm">{{ errors[field.key] }}</p>
                        </div>
                    </div>
                    <div class="mt-5 flex flex-col gap-3 border-t border-[#e8eee9] pt-5 sm:mt-6 sm:pt-6 lg:flex-row lg:justify-end">
                        <button type="button" class="inline-flex h-10 items-center justify-center gap-2 rounded-xl border border-[#d6e2d9] px-5 text-sm font-semibold text-[#526158] transition hover:bg-[#f3f7f4] sm:h-11" @click="resetForm"><RotateCcw :size="16" /> Reset</button>
                        <button type="submit" class="inline-flex h-10 items-center justify-center gap-2 rounded-xl bg-[#1f7a55] px-6 text-sm font-semibold text-white transition hover:bg-[#176344] focus:ring-3 focus:ring-[#2d9468]/25 focus:outline-none sm:h-11"><Calculator :size="16" /> Hitung</button>
                    </div>
                </section>

                <div class="flex items-center gap-3 rounded-2xl bg-[#1f7a55] p-4 text-white shadow-[0_12px_30px_rgba(31,122,85,0.15)] lg:hidden">
                    <span class="flex size-9 shrink-0 items-center justify-center rounded-xl bg-white/15"><Wallet :size="18" /></span>
                    <div class="min-w-0 flex-1">
                        <p class="text-xs font-medium text-[#c5ead5]">TOTAL BRUTO</p>
                        <p class="mt-0.5 truncate text-xl font-semibold tracking-tight">{{ formatRupiah(totalGross) }}</p>
                    </div>
                    <span class="shrink-0 rounded-full bg-white/15 px-2.5 py-0.5 text-[10px] font-medium">Live</span>
                </div>

                <aside class="relative hidden min-w-0 overflow-hidden rounded-2xl bg-[#1f7a55] p-5 text-white shadow-[0_18px_45px_rgba(31,122,85,0.2)] lg:block lg:p-8" aria-labelledby="gross-title">
                    <div class="absolute -top-16 -right-16 size-48 rounded-full border-[20px] border-white/10"></div>
                    <div class="relative">
                        <div class="mb-10 flex items-center justify-between"><span class="flex size-11 items-center justify-center rounded-xl bg-white/15"><Wallet :size="21" /></span><span class="rounded-full bg-white/15 px-3 py-1 text-xs font-medium">Live</span></div>
                        <p class="text-sm text-[#c5ead5]">Ringkasan penghasilan</p>
                        <h2 id="gross-title" class="mt-2 text-xl font-semibold">TOTAL BRUTO</h2>
                        <p class="mt-5 text-3xl font-semibold tracking-tight sm:text-4xl">{{ formatRupiah(totalGross) }}</p>
                        <p class="mt-8 border-t border-white/20 pt-5 text-sm text-[#c5ead5]">Semua komponen penghasilan</p>
                    </div>
                </aside>

                <section class="min-w-0 space-y-5 lg:col-span-2 lg:space-y-6" aria-label="Hasil perhitungan">
                    <div class="grid gap-5 sm:grid-cols-2 sm:gap-6">
                        <article class="min-w-0 rounded-2xl border border-[#dce8df] bg-white p-4 shadow-sm sm:p-6 lg:p-7">
                            <h2 class="text-base font-semibold sm:text-lg">Pengurang</h2>
                            <p class="mt-1 text-xs text-[#718078] sm:text-sm">Komponen yang mengurangi penghasilan bruto.</p>
                            <dl class="mt-4 space-y-3 text-sm sm:mt-6 sm:space-y-4">
                                <div><label for="total-months" class="mb-1.5 block font-medium sm:mb-2">Total Bulan</label><div class="flex items-center gap-3"><input id="total-months" v-model.number="form.totalMonths" type="number" min="1" max="12" step="1" inputmode="numeric" class="h-10 min-w-0 flex-1 rounded-xl border border-[#d6e2d9] bg-[#fbfcfb] px-3 text-sm outline-none focus:border-[#2d9468] focus:ring-3 focus:ring-[#2d9468]/15 sm:h-11" @input="normalizeAmount('totalMonths')" /><span class="shrink-0 text-xs text-[#88958c]">1 – 12</span></div><p class="mt-1 text-xs text-[#88958c]">Maks Rp500.000 per bulan</p></div>
                                <div class="flex flex-wrap items-baseline justify-between gap-x-3 gap-y-1 sm:gap-x-4"><dt class="min-w-0">Biaya Jabatan <span class="text-xs text-[#88958c]">(5%, maks. bulanan × Rp500.000)</span></dt><dd class="shrink-0 font-medium">{{ formatRupiah(positionExpense) }}</dd></div>
                                <div><label for="zakat" class="mb-1.5 block font-medium sm:mb-2">Zakat</label><input id="zakat" :value="formatDisplay(form.zakat)" type="text" inputmode="numeric" class="h-10 w-full rounded-xl border border-[#d6e2d9] bg-[#fbfcfb] px-3 text-sm outline-none focus:border-[#2d9468] focus:ring-3 focus:ring-[#2d9468]/15 sm:h-11" @input="handleAmountInput('zakat', $event)" /></div>
                                <div><label for="employee-jht" class="mb-1.5 block font-medium sm:mb-2">JHT Dit Karyr</label><input id="employee-jht" :value="formatDisplay(form.employeeJht)" type="text" inputmode="numeric" class="h-10 w-full rounded-xl border border-[#d6e2d9] bg-[#fbfcfb] px-3 text-sm outline-none focus:border-[#2d9468] focus:ring-3 focus:ring-[#2d9468]/15 sm:h-11" @input="handleAmountInput('employeeJht', $event)" /></div>
                                <div class="flex flex-wrap items-baseline justify-between gap-x-3 gap-y-1 border-t border-[#e8eee9] pt-3 font-semibold sm:gap-x-4 sm:pt-4"><dt>TOTAL PENGURANG</dt><dd class="shrink-0">{{ formatRupiah(totalDeductions) }}</dd></div>
                            </dl>
                        </article>

                        <article class="min-w-0 rounded-2xl border border-[#dce8df] bg-white p-4 shadow-sm sm:p-6 lg:p-7">
                            <h2 class="text-base font-semibold sm:text-lg">Penghasilan Neto</h2>
                            <p class="mt-1 text-xs text-[#718078] sm:text-sm">Dasar penghasilan setelah pengurang.</p>
                            <p class="mt-6 text-2xl font-semibold text-[#1f7a55] sm:mt-8 sm:text-3xl">{{ formatRupiah(netIncome) }}</p>
                            <div class="mt-5 border-t border-[#e8eee9] pt-4 sm:mt-6 sm:pt-5">
                                <label for="previous-net-income" class="mb-1.5 block text-xs font-medium sm:mb-2 sm:text-sm">Neto Masa Sebelumnya</label>
                                <div class="relative">
                                    <span class="pointer-events-none absolute inset-y-0 left-3 flex items-center text-xs text-[#88958c] sm:left-4 sm:text-sm">Rp</span>
                                    <input id="previous-net-income" :value="formatDisplay(previousNetIncome)" type="text" inputmode="numeric" placeholder="0" class="h-10 w-full rounded-xl border border-[#d6e2d9] bg-[#fbfcfb] pl-10 pr-3 text-sm outline-none transition focus:border-[#2d9468] focus:ring-3 focus:ring-[#2d9468]/15 sm:h-11 sm:pl-12 sm:text-base" @input="handlePreviousNetIncomeInput($event)" />
                                </div>
                                <p class="mt-1.5 text-xs text-[#88958c] sm:mt-2 sm:text-sm">Opsional. Kosongkan jika tidak ada.</p>
                            </div>
                            <div v-if="previousNetIncomeAmount > 0" class="mt-3 flex flex-wrap items-baseline justify-between gap-x-3 gap-y-1 text-xs sm:gap-x-4 sm:text-sm">
                                <span class="text-[#718078]">Total Neto</span>
                                <strong class="shrink-0 text-[#1f7a55]">{{ formatRupiah(totalNetIncome) }}</strong>
                            </div>
                            <div class="mt-5 border-t border-[#e8eee9] pt-4 sm:mt-6 sm:pt-5">
                                <label class="flex items-center gap-3 cursor-pointer select-none">
                                    <input v-model="isAnnualized" type="checkbox" class="size-4 rounded border-[#d6e2d9] text-[#1f7a55] focus:ring-[#2d9468]/25" />
                                    <span class="text-xs font-medium sm:text-sm">Setahunkan Penghasilan Neto</span>
                                </label>
                                <div v-if="isAnnualized" class="mt-3 rounded-xl bg-[#f5f7f4] p-3 space-y-2.5 sm:mt-4 sm:p-4 sm:space-y-3">
                                    <div>
                                        <label for="annualized-months" class="mb-1.5 block text-xs font-medium sm:mb-2 sm:text-sm">Jumlah Bulan</label>
                                        <div class="flex items-center gap-3">
                                            <input id="annualized-months" v-model.number="annualizedMonths" type="range" min="1" max="12" step="1" class="h-2 flex-1 cursor-pointer rounded-lg appearance-none bg-[#d6e2d9] accent-[#1f7a55]" />
                                            <span class="min-w-[3.5rem] rounded-lg border border-[#d6e2d9] bg-white px-2.5 py-1.5 text-center text-xs font-semibold sm:min-w-[4rem] sm:px-3 sm:text-sm">{{ annualizedMonths }} bulan</span>
                                        </div>
                                    </div>
                                    <div class="flex flex-wrap items-baseline justify-between gap-x-3 gap-y-1 text-xs sm:gap-x-4 sm:text-sm">
                                        <span class="text-[#718078]">Neto Disetahunkan</span>
                                        <strong class="shrink-0 text-[#1f7a55]">{{ formatRupiah(annualizedNetIncome) }}</strong>
                                    </div>
                                </div>
                            </div>
                            <div class="mt-5 border-t border-[#e8eee9] pt-4 sm:mt-8 sm:pt-5"><label for="ptkp-status" class="mb-1.5 block text-xs font-medium sm:mb-2 sm:text-sm">Status PTKP <span class="text-[#d34b3e]">*</span></label><select id="ptkp-status" v-model="form.ptkpStatus" :aria-invalid="!!errors.ptkpStatus" class="h-10 w-full rounded-xl border border-[#d6e2d9] bg-[#fbfcfb] px-3 text-sm outline-none focus:border-[#2d9468] focus:ring-3 focus:ring-[#2d9468]/15 aria-[invalid=true]:border-[#d34b3e] sm:h-11" @change="clearError('ptkpStatus')"><option value="" disabled>Pilih status PTKP</option><option value="TK0">TK0</option><option value="K0">K0</option><option value="K1">K1</option><option value="K2">K2</option><option value="K3">K3</option></select><p v-if="errors.ptkpStatus" class="mt-1.5 text-xs text-[#c44135] sm:mt-2 sm:text-sm">{{ errors.ptkpStatus }}</p><p class="mt-2 text-xs text-[#647169] sm:mt-3 sm:text-sm">PTKP: <strong class="text-[#17231d]">{{ formatRupiah(ptkp) }}</strong></p></div>
                        </article>
                    </div>

                    <div class="grid gap-5 sm:grid-cols-2 sm:gap-6">
                        <article class="min-w-0 rounded-2xl border border-[#dce8df] bg-white p-4 shadow-sm sm:p-6 lg:p-7"><p class="text-xs text-[#718078] sm:text-sm">PKP</p><p class="mt-2 text-xl font-semibold sm:text-2xl">{{ formatRupiah(taxableIncome) }}</p><p class="mt-1.5 text-xs text-[#88958c] sm:mt-2">Penghasilan Neto - PTKP</p></article>
                        <article class="min-w-0 rounded-2xl border border-[#dce8df] bg-white p-4 shadow-sm sm:p-6 lg:p-7"><p class="text-xs text-[#718078] sm:text-sm">PPh 21 Terutang</p><p class="mt-2 text-xl font-semibold text-[#1f7a55] sm:text-2xl">{{ formatRupiah(effectiveTaxDue) }}</p><div class="mt-3 space-y-1.5 border-t border-[#e8eee9] pt-3 text-xs text-[#647169] sm:mt-4 sm:space-y-2 sm:pt-4"><div v-for="layer in taxLayers" :key="layer.label" class="flex flex-wrap items-baseline justify-between gap-x-2 gap-y-1 sm:gap-x-3"><span>{{ layer.rate * 100 }}% x {{ formatRupiah(layer.taxable) }}</span><strong>{{ formatRupiah(layer.tax) }}</strong></div></div></article>
                    </div>

                    <article class="min-w-0 rounded-2xl border border-[#dce8df] bg-white p-4 shadow-sm sm:p-6 lg:p-7"><div class="flex flex-col gap-5 md:flex-row md:items-end md:justify-between"><div class="min-w-0"><h2 class="text-base font-semibold sm:text-lg">Kredit Pajak</h2><label for="tax-credit" class="mt-3 mb-1.5 block text-xs font-medium sm:mt-4 sm:mb-2 sm:text-sm">PPh 21 yang Sudah Dipotong/Dibayarkan</label><input id="tax-credit" :value="formatDisplay(form.taxCredit)" type="text" inputmode="numeric" class="h-10 w-full rounded-xl border border-[#d6e2d9] bg-[#fbfcfb] px-3 text-sm outline-none focus:border-[#2d9468] focus:ring-3 focus:ring-[#2d9468]/15 sm:h-11 md:w-80" @input="handleAmountInput('taxCredit', $event)" /></div><div class="min-w-0 md:text-right"><p class="text-xs text-[#718078] sm:text-sm">PPh 21 Masih Harus Dibayar</p><p class="mt-2 text-2xl font-semibold text-[#1f7a55] sm:text-3xl">{{ formatRupiah(remainingTax) }}</p><p v-if="overpayment > 0" class="mt-1.5 text-xs font-semibold text-[#c44135] sm:mt-2 sm:text-sm">Lebih Bayar {{ formatRupiah(overpayment) }}</p><p v-else class="mt-1.5 text-xs text-[#647169] sm:mt-2 sm:text-sm">PPh 21 Terutang - Kredit Pajak</p></div></div></article>
                </section>
            </form>
            <footer class="mt-6 text-center text-xs text-[#88958c] sm:mt-8">Perhitungan ini menggunakan data sementara di browser.</footer>
        </div>
    </main>
</template>
