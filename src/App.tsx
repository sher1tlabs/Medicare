import React, { useState } from 'react';
import {
  Pill,
  Calendar,
  Clock,
  CheckCircle2,
  XCircle,
  Plus,
  Search,
  Bell,
  User as UserIcon,
  ChevronRight,
  ArrowLeft,
  Eye,
  EyeOff,
  MoreVertical,
  Edit2,
  Trash2,
  PauseCircle,
  PlayCircle,
  AlertTriangle,
  FileCode,
  ShieldCheck,
  Heart,
  Droplet,
  Flame,
  Activity,
  Layers,
  Sparkles,
  Smartphone,
  Maximize2,
  Minimize2,
  Volume2,
  Vibrate,
  ListOrdered
} from 'lucide-react';

// Types mimicking Dart Models
interface Medicine {
  id: string;
  name: string;
  genericName: string;
  type: string;
  strength: string;
  dosage: string;
  frequency: string;
  reminderTimes: string[];
  startDate: string;
  endDate?: string;
  instructions: string;
  notes: string;
  isActive: boolean;
  remindersEnabled: boolean;
}

interface Reminder {
  id: string;
  medicineId: string;
  medicineName: string;
  dosage: string;
  type: string;
  time: string;
  isTaken: boolean;
  isSkipped: boolean;
  snoozedUntil?: string;
}

interface MedicationLog {
  id: string;
  medicineId: string;
  medicineName: string;
  dosage: string;
  scheduledTime: string;
  actualTime?: string;
  status: 'taken' | 'skipped' | 'upcoming';
  date: string;
}

interface MedicineInfo {
  id: string;
  name: string;
  genericName: string;
  type: string;
  shortDescription: string;
  commonUses: string[];
  dosageInfo: string;
  sideEffects: string[];
  warnings: string[];
  storageInfo: string;
  precautions: string[];
}

export default function App() {
  // Navigation & View State
  const [deviceFrame, setDeviceFrame] = useState<boolean>(true);
  const [showCodeInspector, setShowCodeInspector] = useState<boolean>(false);
  const [selectedDartFile, setSelectedDartFile] = useState<string>('lib/main.dart');

  // Auth & Session
  const [isLoggedIn, setIsLoggedIn] = useState<boolean>(true);
  const [authView, setAuthView] = useState<'welcome' | 'login' | 'register' | 'forgot'>('welcome');
  const [registerStep, setRegisterStep] = useState<number>(1);
  const [registerForm, setRegisterForm] = useState({
    name: 'Adnan Sher',
    email: 'adnanshersb@gmail.com',
    phone: '+1 (555) 329-8472',
    dob: '1988-05-14',
    password: '',
    confirmPassword: '',
    takesMedicines: true,
    preferredTime: '8:00 AM',
    notifications: true,
  });

  // App Tabs: 0: Home, 1: Medicines, 2: History, 3: Profile
  const [currentTab, setCurrentTab] = useState<number>(0);

  // Sub-screens & Modals
  const [activeScreen, setActiveScreen] = useState<
    'main' | 'add_medicine' | 'medicine_details' | 'medicine_info_list' | 'medicine_info_details' | 'edit_profile' | 'notification_settings'
  >('main');

  const [selectedMedicineId, setSelectedMedicineId] = useState<string>('med_01');
  const [editingMedicine, setEditingMedicine] = useState<Medicine | null>(null);
  const [selectedInfo, setSelectedInfo] = useState<MedicineInfo | null>(null);

  // Settings & Toggles
  const [isDarkMode, setIsDarkMode] = useState<boolean>(false);
  const [snoozeModalReminder, setSnoozeModalReminder] = useState<Reminder | null>(null);
  const [deleteConfirmMed, setDeleteConfirmMed] = useState<Medicine | null>(null);
  const [showLogoutConfirm, setShowLogoutConfirm] = useState<boolean>(false);
  const [notificationToggles, setNotificationToggles] = useState({
    medicationReminders: true,
    reminderSound: true,
    vibration: true,
    dailySummary: true,
    missedMedicationAlerts: true,
  });

  // Search & Filter States
  const [medSearch, setMedSearch] = useState<string>('');
  const [medFilter, setMedFilter] = useState<'All' | 'Active' | 'Paused' | 'Completed'>('All');
  const [historyFilter, setHistoryFilter] = useState<'Today' | 'This Week' | 'This Month'>('Today');
  const [infoSearch, setInfoSearch] = useState<string>('');

  // Initial State Seeds
  const [userProfile, setUserProfile] = useState({
    name: 'Adnan Sher',
    email: 'adnanshersb@gmail.com',
    phone: '+1 (555) 329-8472',
    dob: '1988-05-14',
  });

  const [medicines, setMedicines] = useState<Medicine[]>([
    {
      id: 'med_01',
      name: 'Vitamin D3',
      genericName: 'Cholecalciferol',
      type: 'Capsule',
      strength: '1000 IU',
      dosage: '1 Capsule',
      frequency: 'Once daily',
      reminderTimes: ['8:00 AM'],
      startDate: '2026-08-25',
      instructions: 'Take in the morning with a meal containing fats',
      notes: 'Prescribed by Dr. Robert for bone density support',
      isActive: true,
      remindersEnabled: true,
    },
    {
      id: 'med_02',
      name: 'Metformin',
      genericName: 'Metformin Hydrochloride',
      type: 'Tablet',
      strength: '500 mg',
      dosage: '1 Tablet',
      frequency: 'Twice daily',
      reminderTimes: ['8:00 AM', '8:00 PM'],
      startDate: '2026-06-15',
      instructions: 'Take immediately with or right after meals',
      notes: 'Helps control blood sugar levels',
      isActive: true,
      remindersEnabled: true,
    },
    {
      id: 'med_03',
      name: 'Paracetamol',
      genericName: 'Acetaminophen',
      type: 'Tablet',
      strength: '650 mg',
      dosage: '1 Tablet',
      frequency: 'Three times daily',
      reminderTimes: ['8:00 AM', '1:00 PM', '8:00 PM'],
      startDate: '2026-09-24',
      endDate: '2026-10-01',
      instructions: 'Take with plenty of water',
      notes: 'Mild fever and pain relief post dental procedure',
      isActive: true,
      remindersEnabled: true,
    },
    {
      id: 'med_04',
      name: 'Atorvastatin',
      genericName: 'Atorvastatin Calcium',
      type: 'Tablet',
      strength: '20 mg',
      dosage: '1 Tablet',
      frequency: 'Once daily',
      reminderTimes: ['9:30 PM'],
      startDate: '2026-05-10',
      instructions: 'Take at bedtime',
      notes: 'Cholesterol management',
      isActive: true,
      remindersEnabled: true,
    },
  ]);

  const [reminders, setReminders] = useState<Reminder[]>([
    {
      id: 'rem_01',
      medicineId: 'med_01',
      medicineName: 'Vitamin D3',
      type: 'Capsule',
      dosage: '1 Capsule',
      time: '8:00 AM',
      isTaken: true,
      isSkipped: false,
    },
    {
      id: 'rem_02',
      medicineId: 'med_02',
      medicineName: 'Metformin',
      type: 'Tablet',
      dosage: '1 Tablet',
      time: '8:00 AM',
      isTaken: true,
      isSkipped: false,
    },
    {
      id: 'rem_03',
      medicineId: 'med_03',
      medicineName: 'Paracetamol',
      type: 'Tablet',
      dosage: '1 Tablet',
      time: '1:00 PM',
      isTaken: true,
      isSkipped: false,
    },
    {
      id: 'rem_04',
      medicineId: 'med_02',
      medicineName: 'Metformin',
      type: 'Tablet',
      dosage: '1 Tablet',
      time: '8:00 PM',
      isTaken: false,
      isSkipped: false,
    },
    {
      id: 'rem_05',
      medicineId: 'med_03',
      medicineName: 'Paracetamol',
      type: 'Tablet',
      dosage: '1 Tablet',
      time: '8:00 PM',
      isTaken: false,
      isSkipped: false,
    },
    {
      id: 'rem_06',
      medicineId: 'med_04',
      medicineName: 'Atorvastatin',
      type: 'Tablet',
      dosage: '1 Tablet',
      time: '9:30 PM',
      isTaken: false,
      isSkipped: false,
    },
  ]);

  const [medicationLogs, setMedicationLogs] = useState<MedicationLog[]>([
    {
      id: 'log_01',
      medicineId: 'med_01',
      medicineName: 'Vitamin D3',
      dosage: '1 Capsule',
      scheduledTime: '8:00 AM',
      actualTime: '8:05 AM',
      status: 'taken',
      date: '2026-09-27',
    },
    {
      id: 'log_02',
      medicineId: 'med_02',
      medicineName: 'Metformin',
      dosage: '1 Tablet',
      scheduledTime: '8:00 AM',
      actualTime: '8:12 AM',
      status: 'taken',
      date: '2026-09-27',
    },
    {
      id: 'log_03',
      medicineId: 'med_03',
      medicineName: 'Paracetamol',
      dosage: '1 Tablet',
      scheduledTime: '1:00 PM',
      actualTime: '1:10 PM',
      status: 'taken',
      date: '2026-09-27',
    },
    {
      id: 'log_04',
      medicineId: 'med_03',
      medicineName: 'Paracetamol',
      dosage: '1 Tablet',
      scheduledTime: '8:00 PM',
      status: 'upcoming',
      date: '2026-09-27',
    },
    {
      id: 'log_05',
      medicineId: 'med_02',
      medicineName: 'Metformin',
      dosage: '1 Tablet',
      scheduledTime: '8:00 PM',
      status: 'upcoming',
      date: '2026-09-27',
    },
    {
      id: 'log_06',
      medicineId: 'med_04',
      medicineName: 'Atorvastatin',
      dosage: '1 Tablet',
      scheduledTime: '9:30 PM',
      status: 'upcoming',
      date: '2026-09-27',
    },
    // Past days for adherence history
    {
      id: 'log_hist_1',
      medicineId: 'med_01',
      medicineName: 'Vitamin D3',
      dosage: '1 Capsule',
      scheduledTime: '8:00 AM',
      actualTime: '8:10 AM',
      status: 'taken',
      date: '2026-09-26',
    },
    {
      id: 'log_hist_2',
      medicineId: 'med_02',
      medicineName: 'Metformin',
      dosage: '1 Tablet',
      scheduledTime: '8:00 AM',
      actualTime: '8:15 AM',
      status: 'taken',
      date: '2026-09-26',
    },
    {
      id: 'log_hist_3',
      medicineId: 'med_02',
      medicineName: 'Metformin',
      dosage: '1 Tablet',
      scheduledTime: '8:00 PM',
      status: 'skipped',
      date: '2026-09-26',
    },
  ]);

  const medicineInfos: MedicineInfo[] = [
    {
      id: 'info_01',
      name: 'Paracetamol',
      genericName: 'Acetaminophen',
      type: 'Tablet / Syrup',
      shortDescription: 'A widely used pain reliever and fever reducer.',
      commonUses: [
        'Mild to moderate pain relief (headaches, muscle aches, toothaches)',
        'Fever reduction during colds or flu',
        'Osteoarthritis symptom management',
      ],
      dosageInfo:
        'Adults typically take 500 mg to 1000 mg every 4 to 6 hours as needed. Maximum daily dose should not exceed 4,000 mg in 24 hours to prevent liver toxicity.',
      sideEffects: [
        'Rare at recommended doses',
        'Nausea or stomach upset',
        'Skin rash or allergic reactions (rare)',
      ],
      warnings: [
        'Excessive doses can cause severe and irreversible liver damage.',
        'Avoid consuming alcohol while taking acetaminophen.',
        'Always check if other over-the-counter cough or flu remedies also contain paracetamol to prevent accidental overdose.',
      ],
      storageInfo:
        'Store at room temperature (15°C to 30°C / 59°F to 86°F) away from moisture and direct sunlight.',
      precautions: [
        'Inform your doctor if you have liver disease or severe renal impairment.',
        'Safe for most pregnant and breastfeeding individuals under clinical guidance.',
      ],
    },
    {
      id: 'info_02',
      name: 'Metformin',
      genericName: 'Metformin Hydrochloride',
      type: 'Tablet',
      shortDescription: 'First-line prescription medication for managing type 2 diabetes mellitus.',
      commonUses: [
        'Lowering blood glucose levels in type 2 diabetes',
        'Improving insulin sensitivity',
        'Polycystic ovary syndrome (PCOS) insulin resistance',
      ],
      dosageInfo:
        'Usually initiated at 500 mg once or twice daily with meals to reduce gastrointestinal distress. May be gradually titrated up to 2,000 mg daily by a healthcare provider.',
      sideEffects: [
        'Diarrhea, nausea, stomach cramping',
        'Metallic taste in mouth',
        'Reduced vitamin B12 absorption over long-term use',
      ],
      warnings: [
        'Rare risk of lactic acidosis, especially in patients with acute renal impairment.',
        'Must be temporarily discontinued prior to iodinated contrast radiological procedures.',
      ],
      storageInfo: 'Store between 20°C and 25°C (68°F to 77°F). Keep tightly closed in original bottle.',
      precautions: [
        'Requires routine monitoring of kidney function (eGFR) and vitamin B12 levels.',
        'Take with food to minimize stomach upset.',
      ],
    },
    {
      id: 'info_03',
      name: 'Vitamin D3',
      genericName: 'Cholecalciferol',
      type: 'Capsule / Drops',
      shortDescription: 'Essential fat-soluble vitamin for calcium absorption, bone health, and immune support.',
      commonUses: [
        'Treatment and prevention of vitamin D deficiency',
        'Supporting bone and teeth mineralization',
        'Osteoporosis management in conjunction with calcium',
      ],
      dosageInfo:
        'Maintenance daily doses range from 600 IU to 2,000 IU daily. High-dose weekly regimens (e.g. 50,000 IU) may be prescribed for severe deficiency.',
      sideEffects: [
        'Extremely well tolerated within recommended limits',
        'Hypercalcemia symptoms if mega-dosed (dry mouth, nausea, confusion)',
      ],
      warnings: [
        'Fat-soluble vitamin that accumulates in body fat; do not exceed prescribed doses without blood level testing (25-hydroxy vitamin D).',
      ],
      storageInfo: 'Store in a cool, dry place away from heat and light.',
      precautions: [
        'Take with a meal containing dietary fats for optimal gastrointestinal absorption.',
      ],
    },
    {
      id: 'info_04',
      name: 'Atorvastatin',
      genericName: 'Atorvastatin Calcium',
      type: 'Tablet',
      shortDescription: 'HMG-CoA reductase inhibitor (statin) used to lower LDL cholesterol and triglycerides.',
      commonUses: [
        'Reduction of cardiovascular disease risks (heart attack, stroke)',
        'Hypercholesterolemia management',
        'Atherosclerosis prevention',
      ],
      dosageInfo:
        'Typical starting dose is 10 mg to 20 mg once daily, taken at any time of day (often evening), with or without food. Maximum dose is 80 mg daily.',
      sideEffects: [
        'Mild muscle soreness or arthralgia',
        'Mild elevations in liver enzymes',
        'Digestive disturbances',
      ],
      warnings: [
        'Report unexplained muscle pain, tenderness, or weakness immediately (risk of rhabdomyolysis).',
        'Avoid large quantities of grapefruit juice as it increases drug concentration.',
      ],
      storageInfo: 'Store below 25°C (77°F) in a dry container.',
      precautions: [
        'Periodic liver and lipid panel lab tests are recommended.',
        'Contraindicated during pregnancy and breastfeeding.',
      ],
    },
    {
      id: 'info_05',
      name: 'Amoxicillin',
      genericName: 'Amoxicillin Trihydrate',
      type: 'Capsule / Suspension',
      shortDescription: 'Penicillin-class antibiotic effective against a broad spectrum of bacterial infections.',
      commonUses: [
        'Respiratory tract infections (sinusitis, bronchitis, pneumonia)',
        'Middle ear infections (otitis media)',
        'Skin and urinary tract infections',
      ],
      dosageInfo:
        'Commonly 250 mg to 500 mg every 8 hours, or 875 mg every 12 hours, for 7 to 10 days depending on infection severity.',
      sideEffects: ['Diarrhea, nausea, vomiting', 'Mild cutaneous rash'],
      warnings: [
        'Do NOT take if you have a known allergy to penicillin or cephalosporin antibiotics.',
        'Finish the entire prescribed course even if symptoms improve early.',
      ],
      storageInfo:
        'Capsules at room temperature. Liquid suspension must be refrigerated and discarded after 14 days.',
      precautions: ['Can decrease efficacy of oral contraceptives in some individuals.'],
    },
  ];

  // Actions
  const handleMarkAsTaken = (medicineId: string, time: string) => {
    setReminders((prev) =>
      prev.map((r) =>
        r.medicineId === medicineId && r.time === time
          ? { ...r, isTaken: true, isSkipped: false }
          : r
      )
    );
    const now = new Date();
    const timeStr = `${now.getHours() % 12 || 12}:${String(now.getMinutes()).padStart(2, '0')} ${
      now.getHours() >= 12 ? 'PM' : 'AM'
    }`;
    setMedicationLogs((prev) => [
      ...prev.filter((l) => !(l.medicineId === medicineId && l.scheduledTime === time)),
      {
        id: `log_${Date.now()}`,
        medicineId,
        medicineName: medicines.find((m) => m.id === medicineId)?.name || 'Medicine',
        dosage: medicines.find((m) => m.id === medicineId)?.dosage || '1 dose',
        scheduledTime: time,
        actualTime: timeStr,
        status: 'taken',
        date: '2026-09-27',
      },
    ]);
  };

  const handleMarkAsSkipped = (medicineId: string, time: string) => {
    setReminders((prev) =>
      prev.map((r) =>
        r.medicineId === medicineId && r.time === time
          ? { ...r, isTaken: false, isSkipped: true }
          : r
      )
    );
    setMedicationLogs((prev) => [
      ...prev.filter((l) => !(l.medicineId === medicineId && l.scheduledTime === time)),
      {
        id: `log_${Date.now()}`,
        medicineId,
        medicineName: medicines.find((m) => m.id === medicineId)?.name || 'Medicine',
        dosage: medicines.find((m) => m.id === medicineId)?.dosage || '1 dose',
        scheduledTime: time,
        status: 'skipped',
        date: '2026-09-27',
      },
    ]);
  };

  const handleSnooze = (reminder: Reminder, minutes: number) => {
    const now = new Date();
    now.setMinutes(now.getMinutes() + minutes);
    const timeStr = `${now.getHours() % 12 || 12}:${String(now.getMinutes()).padStart(2, '0')} ${
      now.getHours() >= 12 ? 'PM' : 'AM'
    }`;
    setReminders((prev) =>
      prev.map((r) =>
        r.id === reminder.id ? { ...r, snoozedUntil: `Snoozed until ${timeStr}` } : r
      )
    );
    setSnoozeModalReminder(null);
  };

  const handleDeleteMedicine = (id: string) => {
    setMedicines((prev) => prev.filter((m) => m.id !== id));
    setReminders((prev) => prev.filter((r) => r.medicineId !== id));
    setDeleteConfirmMed(null);
    if (activeScreen === 'medicine_details') {
      setActiveScreen('main');
    }
  };

  const handleToggleMedicineActive = (id: string) => {
    setMedicines((prev) =>
      prev.map((m) => (m.id === id ? { ...m, isActive: !m.isActive } : m))
    );
  };

  // Form state for Add/Edit Medicine
  const [addForm, setAddForm] = useState({
    name: '',
    genericName: '',
    type: 'Tablet',
    strength: '500 mg',
    dosage: '1 Tablet',
    frequency: 'Once daily',
    reminderTimes: ['8:00 AM'],
    startDate: '2026-09-27',
    hasEndDate: false,
    endDate: '2026-10-11',
    instructions: 'Take after food',
    notes: '',
    remindersEnabled: true,
  });

  const openAddMedicine = (medToEdit?: Medicine) => {
    if (medToEdit) {
      setEditingMedicine(medToEdit);
      setAddForm({
        name: medToEdit.name,
        genericName: medToEdit.genericName,
        type: medToEdit.type,
        strength: medToEdit.strength,
        dosage: medToEdit.dosage,
        frequency: medToEdit.frequency,
        reminderTimes: [...medToEdit.reminderTimes],
        startDate: medToEdit.startDate,
        hasEndDate: !!medToEdit.endDate,
        endDate: medToEdit.endDate || '2026-10-11',
        instructions: medToEdit.instructions,
        notes: medToEdit.notes,
        remindersEnabled: medToEdit.remindersEnabled,
      });
    } else {
      setEditingMedicine(null);
      setAddForm({
        name: '',
        genericName: '',
        type: 'Tablet',
        strength: '500 mg',
        dosage: '1 Tablet',
        frequency: 'Once daily',
        reminderTimes: ['8:00 AM'],
        startDate: '2026-09-27',
        hasEndDate: false,
        endDate: '2026-10-11',
        instructions: 'Take after food',
        notes: '',
        remindersEnabled: true,
      });
    }
    setActiveScreen('add_medicine');
  };

  const handleSaveMedicine = () => {
    if (!addForm.name.trim()) return;

    if (editingMedicine) {
      const updated: Medicine = {
        ...editingMedicine,
        name: addForm.name.trim(),
        genericName: addForm.genericName.trim(),
        type: addForm.type,
        strength: addForm.strength.trim(),
        dosage: addForm.dosage.trim(),
        frequency: addForm.frequency,
        reminderTimes: addForm.reminderTimes,
        startDate: addForm.startDate,
        endDate: addForm.hasEndDate ? addForm.endDate : undefined,
        instructions: addForm.instructions.trim(),
        notes: addForm.notes.trim(),
        remindersEnabled: addForm.remindersEnabled,
      };
      setMedicines((prev) => prev.map((m) => (m.id === updated.id ? updated : m)));
    } else {
      const newMed: Medicine = {
        id: `med_${Date.now()}`,
        name: addForm.name.trim(),
        genericName: addForm.genericName.trim(),
        type: addForm.type,
        strength: addForm.strength.trim(),
        dosage: addForm.dosage.trim(),
        frequency: addForm.frequency,
        reminderTimes: addForm.reminderTimes,
        startDate: addForm.startDate,
        endDate: addForm.hasEndDate ? addForm.endDate : undefined,
        instructions: addForm.instructions.trim(),
        notes: addForm.notes.trim(),
        isActive: true,
        remindersEnabled: addForm.remindersEnabled,
      };
      setMedicines((prev) => [newMed, ...prev]);

      // Add reminders for today
      const newRems: Reminder[] = addForm.reminderTimes.map((t, idx) => ({
        id: `rem_${Date.now()}_${idx}`,
        medicineId: newMed.id,
        medicineName: newMed.name,
        dosage: newMed.dosage,
        type: newMed.type,
        time: t,
        isTaken: false,
        isSkipped: false,
      }));
      setReminders((prev) => [...prev, ...newRems]);
    }

    setActiveScreen('main');
  };

  // Calculations for dashboard
  const todayTaken = reminders.filter((r) => r.isTaken).length;
  const todayTotal = reminders.length;
  const progressPercent = todayTotal === 0 ? 0 : Math.round((todayTaken / todayTotal) * 100);
  const nextReminder = reminders.find((r) => !r.isTaken && !r.isSkipped);

  // Filtered medicines
  const filteredMedicines = medicines.filter((m) => {
    const matchesSearch =
      m.name.toLowerCase().includes(medSearch.toLowerCase()) ||
      m.genericName.toLowerCase().includes(medSearch.toLowerCase());
    if (!matchesSearch) return false;
    if (medFilter === 'Active') return m.isActive;
    if (medFilter === 'Paused') return !m.isActive;
    if (medFilter === 'Completed') return m.endDate && new Date(m.endDate) < new Date();
    return true;
  });

  // Flutter Code viewer map
  const dartCodeSnippets: Record<string, string> = {
    'pubspec.yaml': `name: medicare
description: "MediCare - Your medicines. Your schedule. Your health. Modern, clean medicine reminder and information app."
publish_to: "none"
version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.10.0"

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8

flutter:
  uses-material-design: true`,
    'lib/main.dart': `import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MediCareApp());
}`,
    'lib/models/medicine.dart': `class Medicine {
  final String id;
  final String name;
  final String genericName;
  final String type; // Tablet, Capsule, Syrup, Injection, Cream, Drops, Other
  final String strength;
  final String dosage;
  final String frequency;
  final List<String> reminderTimes;
  final DateTime startDate;
  final DateTime? endDate;
  final String instructions;
  final String notes;
  final bool isActive;
  final bool remindersEnabled;

  const Medicine({
    required this.id,
    required this.name,
    this.genericName = '',
    required this.type,
    required this.strength,
    required this.dosage,
    required this.frequency,
    required this.reminderTimes,
    required this.startDate,
    this.endDate,
    this.instructions = '',
    this.notes = '',
    this.isActive = true,
    this.remindersEnabled = true,
  });
}`,
    'lib/screens/home/home_screen.dart': `// Flutter Material 3 Home Dashboard
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text("Good Morning, Adnan", style: Theme.of(context).textTheme.headlineMedium),
            ProgressCard(taken: 4, total: 6, percentage: 0.67),
            const SizedBox(height: 20),
            NextReminderCard(...),
            QuickActionsGrid(...),
            TodayScheduleList(...),
          ],
        ),
      ),
    );
  }
}`,
    'lib/theme/app_theme.dart': `// Healthcare-focused Material 3 ThemeData
class AppTheme {
  static const Color primaryColor = Color(0xFF0D9488); // Medical Teal
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}`,
  };

  return (
    <div className={`min-h-screen flex flex-col ${isDarkMode ? 'bg-slate-950 text-slate-100' : 'bg-slate-100 text-slate-900'} antialiased font-sans`}>
      {/* Top Banner & Control Bar */}
      <header className="bg-teal-900 text-white px-4 py-3 shadow-md flex items-center justify-between border-b border-teal-800 z-50">
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-xl bg-teal-500/20 border border-teal-400/30 flex items-center justify-center text-teal-300">
            <Pill className="w-5 h-5" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <span className="font-bold tracking-tight text-lg text-white">MediCare</span>
              <span className="text-[11px] px-2 py-0.5 rounded-full font-semibold bg-emerald-500/20 text-emerald-300 border border-emerald-400/30">
                Flutter 3.x / Dart Native
              </span>
            </div>
            <p className="text-xs text-teal-200/80 hidden sm:block">
              Your medicines. Your schedule. Your health.
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={() => setShowCodeInspector(!showCodeInspector)}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold transition ${
              showCodeInspector ? 'bg-teal-500 text-white' : 'bg-teal-800/80 hover:bg-teal-700 text-teal-100'
            }`}
          >
            <FileCode className="w-4 h-4" />
            <span className="hidden md:inline">Flutter Project Code</span>
          </button>

          <button
            onClick={() => setDeviceFrame(!deviceFrame)}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold bg-teal-800/80 hover:bg-teal-700 text-teal-100 transition"
            title="Toggle Mobile Device Shell"
          >
            <Smartphone className="w-4 h-4" />
            <span className="hidden md:inline">{deviceFrame ? 'Mobile Frame' : 'Full Screen'}</span>
          </button>
        </div>
      </header>

      {/* Main Container */}
      <div className="flex-1 flex overflow-hidden">
        {/* Mobile Phone Mockup or Expanded Container */}
        <main className={`flex-1 flex items-center justify-center p-2 sm:p-6 overflow-y-auto ${isDarkMode ? 'bg-slate-900' : 'bg-slate-200/60'}`}>
          <div
            className={`w-full transition-all duration-300 ${
              deviceFrame
                ? 'max-w-[420px] h-[850px] max-h-[92vh] rounded-[44px] shadow-2xl border-[10px] border-slate-800 ring-1 ring-slate-900/10'
                : 'max-w-4xl min-h-[85vh] rounded-3xl shadow-xl border border-slate-200'
            } ${isDarkMode ? 'bg-slate-900 text-slate-100' : 'bg-white text-slate-900'} flex flex-col relative overflow-hidden`}
          >
            {/* Native Mobile Status Bar */}
            {deviceFrame && (
              <div className="h-7 bg-slate-900 text-white flex items-center justify-between px-6 text-[11px] font-medium tracking-tight select-none">
                <span>9:41</span>
                <div className="w-20 h-4 bg-slate-950 rounded-b-xl mx-auto -mt-1 flex items-center justify-center">
                  <div className="w-10 h-1 bg-slate-800 rounded-full" />
                </div>
                <div className="flex items-center gap-1.5 text-xs">
                  <span>5G</span>
                  <div className="w-4 h-2.5 border border-white/80 rounded-sm p-0.5 flex items-center">
                    <div className="h-full w-2.5 bg-white rounded-2xs" />
                  </div>
                </div>
              </div>
            )}

            {/* Mobile App Screen Content */}
            <div className="flex-1 flex flex-col overflow-y-auto relative">
              {/* AUTHENTICATION SCREENS */}
              {!isLoggedIn ? (
                authView === 'welcome' ? (
                  <div className="flex-1 flex flex-col p-8 justify-between">
                    <div className="flex-1 flex flex-col items-center justify-center text-center">
                      <div className="w-24 h-24 rounded-3xl bg-gradient-to-br from-teal-500 to-sky-600 flex items-center justify-center shadow-lg shadow-teal-500/25 mb-6 text-white">
                        <Pill className="w-12 h-12" />
                      </div>
                      <h1 className="text-3xl font-extrabold text-slate-900 tracking-tight mb-2">
                        MediCare
                      </h1>
                      <p className="text-base text-slate-500 font-medium leading-relaxed max-w-xs">
                        Your medicines. Your schedule. Your health.
                      </p>
                    </div>

                    <div className="space-y-3">
                      <button
                        onClick={() => {
                          setAuthView('register');
                          setRegisterStep(1);
                        }}
                        className="w-full py-3.5 px-4 bg-teal-600 hover:bg-teal-700 text-white rounded-2xl font-bold text-base shadow-sm transition active:scale-[0.98]"
                      >
                        Get Started
                      </button>
                      <button
                        onClick={() => setAuthView('login')}
                        className="w-full py-3.5 px-4 bg-transparent border-2 border-teal-600 text-teal-700 hover:bg-teal-50 rounded-2xl font-bold text-base transition active:scale-[0.98]"
                      >
                        Login
                      </button>
                      <p className="text-center text-xs text-slate-400 pt-2">
                        By continuing, you agree to our Terms & Privacy Policy.
                      </p>
                    </div>
                  </div>
                ) : authView === 'login' ? (
                  <div className="flex-1 flex flex-col p-6 overflow-y-auto">
                    <button
                      onClick={() => setAuthView('welcome')}
                      className="self-start p-2 -ml-2 text-slate-500 hover:text-slate-900 rounded-full"
                    >
                      <ArrowLeft className="w-5 h-5" />
                    </button>
                    <div className="mt-4 mb-6">
                      <h2 className="text-2xl font-bold text-slate-900">Welcome Back</h2>
                      <p className="text-sm text-slate-500 mt-1">Sign in to access your reminders</p>
                    </div>

                    <div className="space-y-4 flex-1">
                      <div>
                        <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                          Email Address
                        </label>
                        <input
                          type="email"
                          defaultValue="adnanshersb@gmail.com"
                          className="w-full px-4 py-3 bg-slate-100 border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:border-teal-600"
                        />
                      </div>
                      <div>
                        <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                          Password
                        </label>
                        <input
                          type="password"
                          defaultValue="••••••••••••"
                          className="w-full px-4 py-3 bg-slate-100 border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:border-teal-600"
                        />
                      </div>
                      <div className="flex items-center justify-between text-xs pt-1">
                        <label className="flex items-center gap-2 text-slate-600 cursor-pointer">
                          <input type="checkbox" defaultChecked className="rounded text-teal-600" />
                          <span>Remember me</span>
                        </label>
                        <button
                          type="button"
                          onClick={() => setAuthView('forgot')}
                          className="text-teal-600 font-semibold hover:underline"
                        >
                          Forgot Password?
                        </button>
                      </div>

                      <button
                        onClick={() => setIsLoggedIn(true)}
                        className="w-full mt-6 py-3.5 bg-teal-600 hover:bg-teal-700 text-white rounded-2xl font-bold text-base shadow-sm transition active:scale-[0.98]"
                      >
                        Login
                      </button>
                    </div>

                    <p className="text-center text-xs text-slate-500 pt-4">
                      Don't have an account?{' '}
                      <button
                        onClick={() => {
                          setAuthView('register');
                          setRegisterStep(1);
                        }}
                        className="text-teal-600 font-bold hover:underline"
                      >
                        Create Account
                      </button>
                    </p>
                  </div>
                ) : authView === 'register' ? (
                  <div className="flex-1 flex flex-col p-6 overflow-y-auto">
                    <button
                      onClick={() => {
                        if (registerStep > 1) setRegisterStep(registerStep - 1);
                        else setAuthView('welcome');
                      }}
                      className="self-start p-2 -ml-2 text-slate-500 hover:text-slate-900 rounded-full"
                    >
                      <ArrowLeft className="w-5 h-5" />
                    </button>

                    <div className="mt-2 mb-4">
                      <div className="flex items-center justify-between text-xs text-slate-500 font-semibold mb-2">
                        <span>Step {registerStep} of 3</span>
                        <span>{registerStep === 1 ? 'Personal Info' : registerStep === 2 ? 'Security' : 'Preferences'}</span>
                      </div>
                      <div className="w-full h-1.5 bg-slate-200 rounded-full overflow-hidden">
                        <div
                          className="h-full bg-teal-600 transition-all duration-300"
                          style={{ width: `${(registerStep / 3) * 100}%` }}
                        />
                      </div>
                    </div>

                    {registerStep === 1 && (
                      <div className="space-y-3.5 flex-1">
                        <h3 className="text-xl font-bold text-slate-900">Personal Details</h3>
                        <p className="text-xs text-slate-500">Let us get to know you better</p>
                        <div>
                          <label className="block text-xs font-semibold text-slate-700 mb-1">Full Name</label>
                          <input
                            type="text"
                            value={registerForm.name}
                            onChange={(e) => setRegisterForm({ ...registerForm, name: e.target.value })}
                            className="w-full px-3.5 py-2.5 bg-slate-100 border border-slate-200 rounded-xl text-sm"
                          />
                        </div>
                        <div>
                          <label className="block text-xs font-semibold text-slate-700 mb-1">Email</label>
                          <input
                            type="email"
                            value={registerForm.email}
                            onChange={(e) => setRegisterForm({ ...registerForm, email: e.target.value })}
                            className="w-full px-3.5 py-2.5 bg-slate-100 border border-slate-200 rounded-xl text-sm"
                          />
                        </div>
                        <div>
                          <label className="block text-xs font-semibold text-slate-700 mb-1">Phone Number</label>
                          <input
                            type="tel"
                            value={registerForm.phone}
                            onChange={(e) => setRegisterForm({ ...registerForm, phone: e.target.value })}
                            className="w-full px-3.5 py-2.5 bg-slate-100 border border-slate-200 rounded-xl text-sm"
                          />
                        </div>
                        <div>
                          <label className="block text-xs font-semibold text-slate-700 mb-1">Date of Birth</label>
                          <input
                            type="date"
                            value={registerForm.dob}
                            onChange={(e) => setRegisterForm({ ...registerForm, dob: e.target.value })}
                            className="w-full px-3.5 py-2.5 bg-slate-100 border border-slate-200 rounded-xl text-sm"
                          />
                        </div>
                        <button
                          onClick={() => setRegisterStep(2)}
                          className="w-full mt-4 py-3 bg-teal-600 text-white rounded-xl font-bold text-sm"
                        >
                          Continue
                        </button>
                      </div>
                    )}

                    {registerStep === 2 && (
                      <div className="space-y-3.5 flex-1">
                        <h3 className="text-xl font-bold text-slate-900">Set Password</h3>
                        <p className="text-xs text-slate-500">Protect your health profile</p>
                        <div>
                          <label className="block text-xs font-semibold text-slate-700 mb-1">Password</label>
                          <input
                            type="password"
                            placeholder="At least 8 characters"
                            className="w-full px-3.5 py-2.5 bg-slate-100 border border-slate-200 rounded-xl text-sm"
                          />
                        </div>
                        <div>
                          <label className="block text-xs font-semibold text-slate-700 mb-1">Confirm Password</label>
                          <input
                            type="password"
                            placeholder="Re-enter password"
                            className="w-full px-3.5 py-2.5 bg-slate-100 border border-slate-200 rounded-xl text-sm"
                          />
                        </div>
                        <div className="p-3 bg-slate-50 border border-slate-200 rounded-xl text-xs space-y-1 text-slate-600">
                          <p className="font-semibold text-slate-800">Requirements:</p>
                          <p>✓ At least 8 characters</p>
                          <p>✓ At least one number</p>
                          <p>✓ At least one special character</p>
                        </div>
                        <button
                          onClick={() => setRegisterStep(3)}
                          className="w-full mt-4 py-3 bg-teal-600 text-white rounded-xl font-bold text-sm"
                        >
                          Create Account
                        </button>
                      </div>
                    )}

                    {registerStep === 3 && (
                      <div className="space-y-4 flex-1">
                        <h3 className="text-xl font-bold text-slate-900">Preferences</h3>
                        <p className="text-xs text-slate-500">Personalize your dose alerts</p>

                        <div className="space-y-2">
                          <span className="block text-xs font-semibold text-slate-700">
                            Do you currently take medicines?
                          </span>
                          <div className="grid grid-cols-2 gap-2">
                            <button
                              onClick={() => setRegisterForm({ ...registerForm, takesMedicines: true })}
                              className={`py-2 text-xs font-bold rounded-xl border ${
                                registerForm.takesMedicines ? 'bg-teal-50 border-teal-600 text-teal-700' : 'bg-slate-100 border-slate-200 text-slate-600'
                              }`}
                            >
                              Yes
                            </button>
                            <button
                              onClick={() => setRegisterForm({ ...registerForm, takesMedicines: false })}
                              className={`py-2 text-xs font-bold rounded-xl border ${
                                !registerForm.takesMedicines ? 'bg-teal-50 border-teal-600 text-teal-700' : 'bg-slate-100 border-slate-200 text-slate-600'
                              }`}
                            >
                              No
                            </button>
                          </div>
                        </div>

                        <div>
                          <label className="block text-xs font-semibold text-slate-700 mb-1">Preferred Reminder Time</label>
                          <select
                            value={registerForm.preferredTime}
                            onChange={(e) => setRegisterForm({ ...registerForm, preferredTime: e.target.value })}
                            className="w-full px-3.5 py-2.5 bg-slate-100 border border-slate-200 rounded-xl text-sm"
                          >
                            <option value="7:00 AM">7:00 AM (Early Morning)</option>
                            <option value="8:00 AM">8:00 AM (Morning)</option>
                            <option value="1:00 PM">1:00 PM (Afternoon)</option>
                            <option value="8:00 PM">8:00 PM (Evening)</option>
                          </select>
                        </div>

                        <div className="p-4 bg-teal-50 border border-teal-200 rounded-2xl text-center space-y-2">
                          <CheckCircle2 className="w-8 h-8 text-teal-600 mx-auto" />
                          <h4 className="font-bold text-teal-900 text-sm">Your account is ready!</h4>
                          <p className="text-xs text-teal-700">
                            We've pre-loaded your dashboard with a starter schedule.
                          </p>
                        </div>

                        <button
                          onClick={() => {
                            setIsLoggedIn(true);
                            setActiveScreen('main');
                            setCurrentTab(0);
                          }}
                          className="w-full py-3 bg-teal-600 text-white rounded-xl font-bold text-sm"
                        >
                          Go to Home
                        </button>
                      </div>
                    )}
                  </div>
                ) : (
                  <div className="flex-1 flex flex-col p-6 justify-between">
                    <div>
                      <button
                        onClick={() => setAuthView('login')}
                        className="p-2 -ml-2 text-slate-500 hover:text-slate-900 rounded-full"
                      >
                        <ArrowLeft className="w-5 h-5" />
                      </button>
                      <h2 className="text-2xl font-bold text-slate-900 mt-4">Reset Password</h2>
                      <p className="text-sm text-slate-500 mt-1">
                        Enter your email to receive a password reset link.
                      </p>
                      <div className="mt-6">
                        <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                          Email Address
                        </label>
                        <input
                          type="email"
                          placeholder="name@example.com"
                          className="w-full px-4 py-3 bg-slate-100 border border-slate-200 rounded-xl text-sm"
                        />
                      </div>
                      <button
                        onClick={() => alert('Reset link sent to your email!')}
                        className="w-full mt-4 py-3.5 bg-teal-600 text-white rounded-xl font-bold text-sm"
                      >
                        Send Reset Link
                      </button>
                    </div>
                    <button
                      onClick={() => setAuthView('login')}
                      className="text-xs text-teal-600 font-bold text-center py-2"
                    >
                      Back to Login
                    </button>
                  </div>
                )
              ) : activeScreen === 'add_medicine' ? (
                /* ADD / EDIT MEDICINE FORM SCREEN */
                <div className="flex-1 flex flex-col bg-slate-50 overflow-y-auto">
                  <div className="p-4 bg-white border-b border-slate-200 flex items-center justify-between sticky top-0 z-10">
                    <button
                      onClick={() => setActiveScreen('main')}
                      className="p-1.5 -ml-1 text-slate-600 hover:text-slate-900 rounded-lg"
                    >
                      <ArrowLeft className="w-5 h-5" />
                    </button>
                    <h2 className="font-bold text-base text-slate-900">
                      {editingMedicine ? 'Edit Medicine' : 'Add Medicine'}
                    </h2>
                    <div className="w-8" />
                  </div>

                  <div className="p-4 space-y-4">
                    {/* Medicine Information */}
                    <div className="bg-white p-4 rounded-2xl border border-slate-200 space-y-3">
                      <div className="flex items-center gap-2 text-teal-700 font-bold text-sm">
                        <Pill className="w-4 h-4" />
                        <span>Medicine Information</span>
                      </div>
                      <div>
                        <label className="block text-xs font-semibold text-slate-700 mb-1">
                          Medicine Name *
                        </label>
                        <input
                          type="text"
                          placeholder="e.g. Paracetamol, Amoxicillin"
                          value={addForm.name}
                          onChange={(e) => setAddForm({ ...addForm, name: e.target.value })}
                          className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm font-medium"
                        />
                      </div>
                      <div>
                        <label className="block text-xs font-semibold text-slate-700 mb-1">
                          Generic Name (Optional)
                        </label>
                        <input
                          type="text"
                          placeholder="e.g. Acetaminophen"
                          value={addForm.genericName}
                          onChange={(e) => setAddForm({ ...addForm, genericName: e.target.value })}
                          className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm font-medium"
                        />
                      </div>
                      <div className="grid grid-cols-2 gap-2">
                        <div>
                          <label className="block text-xs font-semibold text-slate-700 mb-1">Type</label>
                          <select
                            value={addForm.type}
                            onChange={(e) => setAddForm({ ...addForm, type: e.target.value })}
                            className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm font-medium"
                          >
                            <option>Tablet</option>
                            <option>Capsule</option>
                            <option>Syrup</option>
                            <option>Injection</option>
                            <option>Cream</option>
                            <option>Drops</option>
                            <option>Other</option>
                          </select>
                        </div>
                        <div>
                          <label className="block text-xs font-semibold text-slate-700 mb-1">Strength</label>
                          <input
                            type="text"
                            placeholder="e.g. 500 mg"
                            value={addForm.strength}
                            onChange={(e) => setAddForm({ ...addForm, strength: e.target.value })}
                            className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm font-medium"
                          />
                        </div>
                      </div>
                    </div>

                    {/* Dosage & Schedule */}
                    <div className="bg-white p-4 rounded-2xl border border-slate-200 space-y-3">
                      <div className="flex items-center gap-2 text-teal-700 font-bold text-sm">
                        <Clock className="w-4 h-4" />
                        <span>Dosage & Schedule</span>
                      </div>
                      <div>
                        <label className="block text-xs font-semibold text-slate-700 mb-1">Dosage</label>
                        <input
                          type="text"
                          placeholder="e.g. 1 Tablet, 5 ml"
                          value={addForm.dosage}
                          onChange={(e) => setAddForm({ ...addForm, dosage: e.target.value })}
                          className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm font-medium"
                        />
                      </div>
                      <div>
                        <label className="block text-xs font-semibold text-slate-700 mb-1">Frequency</label>
                        <select
                          value={addForm.frequency}
                          onChange={(e) => setAddForm({ ...addForm, frequency: e.target.value })}
                          className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm font-medium"
                        >
                          <option>Once daily</option>
                          <option>Twice daily</option>
                          <option>Three times daily</option>
                          <option>Every 8 hours</option>
                          <option>Weekly</option>
                          <option>Custom</option>
                        </select>
                      </div>

                      {/* Reminder Times chips */}
                      <div>
                        <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                          Reminder Times
                        </label>
                        <div className="flex flex-wrap gap-2 mb-2">
                          {addForm.reminderTimes.map((t, idx) => (
                            <span
                              key={idx}
                              className="px-3 py-1 bg-teal-50 text-teal-800 border border-teal-200 rounded-full text-xs font-bold flex items-center gap-1.5"
                            >
                              {t}
                              {addForm.reminderTimes.length > 1 && (
                                <button
                                  type="button"
                                  onClick={() =>
                                    setAddForm({
                                      ...addForm,
                                      reminderTimes: addForm.reminderTimes.filter((_, i) => i !== idx),
                                    })
                                  }
                                  className="text-teal-600 hover:text-teal-900"
                                >
                                  ×
                                </button>
                              )}
                            </span>
                          ))}
                        </div>
                        <button
                          type="button"
                          onClick={() => {
                            const newTime = prompt('Enter reminder time (e.g. 2:00 PM):', '2:00 PM');
                            if (newTime && !addForm.reminderTimes.includes(newTime)) {
                              setAddForm({
                                ...addForm,
                                reminderTimes: [...addForm.reminderTimes, newTime],
                              });
                            }
                          }}
                          className="text-xs text-teal-700 font-bold border border-dashed border-teal-300 px-3 py-1.5 rounded-lg flex items-center gap-1 hover:bg-teal-50"
                        >
                          <Plus className="w-3.5 h-3.5" />
                          Add Another Time
                        </button>
                      </div>
                    </div>

                    {/* Additional Details */}
                    <div className="bg-white p-4 rounded-2xl border border-slate-200 space-y-3">
                      <div>
                        <label className="block text-xs font-semibold text-slate-700 mb-1">
                          Instructions
                        </label>
                        <input
                          type="text"
                          placeholder="e.g. Take after food with water"
                          value={addForm.instructions}
                          onChange={(e) => setAddForm({ ...addForm, instructions: e.target.value })}
                          className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm"
                        />
                      </div>
                      <div>
                        <label className="block text-xs font-semibold text-slate-700 mb-1">
                          Doctor Notes / Remarks
                        </label>
                        <textarea
                          rows={2}
                          placeholder="Special indications or warnings"
                          value={addForm.notes}
                          onChange={(e) => setAddForm({ ...addForm, notes: e.target.value })}
                          className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm"
                        />
                      </div>
                      <div className="flex items-center justify-between pt-1">
                        <div>
                          <p className="text-xs font-bold text-slate-800">Alarms & Notifications</p>
                          <p className="text-[11px] text-slate-500">Play chimes and vibrate device</p>
                        </div>
                        <input
                          type="checkbox"
                          checked={addForm.remindersEnabled}
                          onChange={(e) =>
                            setAddForm({ ...addForm, remindersEnabled: e.target.checked })
                          }
                          className="w-4 h-4 text-teal-600 rounded"
                        />
                      </div>
                    </div>

                    <button
                      onClick={handleSaveMedicine}
                      className="w-full py-3.5 bg-teal-600 hover:bg-teal-700 text-white rounded-2xl font-bold text-sm shadow-md transition"
                    >
                      {editingMedicine ? 'Update Medicine' : 'Save Medicine'}
                    </button>
                  </div>
                </div>
              ) : activeScreen === 'medicine_details' ? (
                /* MEDICINE DETAILS SCREEN */
                (() => {
                  const med = medicines.find((m) => m.id === selectedMedicineId);
                  if (!med) return <div className="p-6">Medicine not found</div>;
                  const logs = medicationLogs.filter((l) => l.medicineId === med.id);

                  return (
                    <div className="flex-1 flex flex-col bg-slate-50 overflow-y-auto">
                      <div className="p-4 bg-white border-b border-slate-200 flex items-center justify-between sticky top-0 z-10">
                        <button
                          onClick={() => setActiveScreen('main')}
                          className="p-1.5 -ml-1 text-slate-600 hover:text-slate-900 rounded-lg"
                        >
                          <ArrowLeft className="w-5 h-5" />
                        </button>
                        <h2 className="font-bold text-base text-slate-900">Medicine Details</h2>
                        <div className="flex items-center gap-1">
                          <button
                            onClick={() => openAddMedicine(med)}
                            className="p-1.5 text-teal-600 hover:text-teal-900"
                            title="Edit"
                          >
                            <Edit2 className="w-4 h-4" />
                          </button>
                          <button
                            onClick={() => setDeleteConfirmMed(med)}
                            className="p-1.5 text-red-600 hover:text-red-900"
                            title="Delete"
                          >
                            <Trash2 className="w-4 h-4" />
                          </button>
                        </div>
                      </div>

                      <div className="p-4 space-y-4">
                        {/* Hero Card */}
                        <div className="bg-gradient-to-br from-teal-600 to-teal-800 text-white p-5 rounded-3xl shadow-md">
                          <div className="flex justify-between items-start">
                            <span className="px-2.5 py-1 bg-white/20 rounded-lg text-xs font-bold">
                              {med.type}
                            </span>
                            <span
                              className={`px-2.5 py-1 rounded-lg text-xs font-bold ${
                                med.isActive ? 'bg-emerald-400/20 text-emerald-200 border border-emerald-300/30' : 'bg-slate-800/40 text-slate-300'
                              }`}
                            >
                              {med.isActive ? 'Active' : 'Paused'}
                            </span>
                          </div>
                          <h1 className="text-2xl font-black mt-3">{med.name}</h1>
                          {med.genericName && (
                            <p className="text-xs text-teal-100/80 italic mt-0.5">{med.genericName}</p>
                          )}
                          <div className="grid grid-cols-3 gap-2 mt-4 pt-3 border-t border-white/10 text-xs">
                            <div>
                              <p className="text-teal-200/80 text-[10px]">Strength</p>
                              <p className="font-bold">{med.strength}</p>
                            </div>
                            <div>
                              <p className="text-teal-200/80 text-[10px]">Dosage</p>
                              <p className="font-bold">{med.dosage}</p>
                            </div>
                            <div>
                              <p className="text-teal-200/80 text-[10px]">Frequency</p>
                              <p className="font-bold truncate">{med.frequency}</p>
                            </div>
                          </div>
                        </div>

                        {/* Action buttons */}
                        <button
                          onClick={() => handleToggleMedicineActive(med.id)}
                          className={`w-full py-2.5 rounded-xl font-bold text-xs border flex items-center justify-center gap-1.5 ${
                            med.isActive
                              ? 'bg-amber-50 text-amber-800 border-amber-200'
                              : 'bg-emerald-50 text-emerald-800 border-emerald-200'
                          }`}
                        >
                          {med.isActive ? (
                            <>
                              <PauseCircle className="w-4 h-4" /> Pause Medication
                            </>
                          ) : (
                            <>
                              <PlayCircle className="w-4 h-4" /> Resume Medication
                            </>
                          )}
                        </button>

                        {/* Schedule Specifications */}
                        <div className="bg-white p-4 rounded-2xl border border-slate-200 space-y-2.5 text-xs">
                          <h3 className="font-bold text-slate-900 text-sm mb-1">Schedule & Instructions</h3>
                          <div className="flex justify-between py-1.5 border-b border-slate-100">
                            <span className="text-slate-500">Reminder Times</span>
                            <span className="font-bold text-slate-800">{med.reminderTimes.join(', ')}</span>
                          </div>
                          <div className="flex justify-between py-1.5 border-b border-slate-100">
                            <span className="text-slate-500">Start Date</span>
                            <span className="font-bold text-slate-800">{med.startDate}</span>
                          </div>
                          <div className="flex justify-between py-1.5 border-b border-slate-100">
                            <span className="text-slate-500">End Date</span>
                            <span className="font-bold text-slate-800">{med.endDate || 'Ongoing'}</span>
                          </div>
                          {med.instructions && (
                            <div className="py-1.5 border-b border-slate-100">
                              <span className="text-slate-500 block mb-0.5">Instructions</span>
                              <span className="font-medium text-slate-800">{med.instructions}</span>
                            </div>
                          )}
                          {med.notes && (
                            <div className="py-1.5">
                              <span className="text-slate-500 block mb-0.5">Notes</span>
                              <span className="font-medium text-slate-800">{med.notes}</span>
                            </div>
                          )}
                        </div>

                        {/* History Log */}
                        <div className="bg-white p-4 rounded-2xl border border-slate-200">
                          <h3 className="font-bold text-slate-900 text-sm mb-3">Medication History</h3>
                          {logs.length === 0 ? (
                            <p className="text-xs text-slate-400 text-center py-4">No logged doses yet</p>
                          ) : (
                            <div className="space-y-2">
                              {logs.map((l) => (
                                <div
                                  key={l.id}
                                  className="p-2.5 rounded-xl border border-slate-100 flex items-center justify-between text-xs"
                                >
                                  <div className="flex items-center gap-2">
                                    {l.status === 'taken' ? (
                                      <CheckCircle2 className="w-4 h-4 text-emerald-600" />
                                    ) : l.status === 'skipped' ? (
                                      <XCircle className="w-4 h-4 text-red-500" />
                                    ) : (
                                      <Clock className="w-4 h-4 text-slate-400" />
                                    )}
                                    <div>
                                      <p className="font-bold text-slate-800">
                                        {l.scheduledTime} — {l.status === 'taken' ? 'Taken' : l.status === 'skipped' ? 'Skipped' : 'Upcoming'}
                                      </p>
                                      {l.actualTime && (
                                        <p className="text-[10px] text-teal-600">Logged at {l.actualTime}</p>
                                      )}
                                    </div>
                                  </div>
                                  <span className="text-[10px] text-slate-400 font-medium">{l.date}</span>
                                </div>
                              ))}
                            </div>
                          )}
                        </div>
                      </div>
                    </div>
                  );
                })()
              ) : activeScreen === 'medicine_info_list' ? (
                /* MEDICINE INFORMATION LIST */
                <div className="flex-1 flex flex-col bg-slate-50 overflow-y-auto">
                  <div className="p-4 bg-white border-b border-slate-200 flex items-center justify-between sticky top-0 z-10">
                    <button
                      onClick={() => setActiveScreen('main')}
                      className="p-1.5 -ml-1 text-slate-600 hover:text-slate-900 rounded-lg"
                    >
                      <ArrowLeft className="w-5 h-5" />
                    </button>
                    <h2 className="font-bold text-base text-slate-900">Medicine Guide</h2>
                    <div className="w-8" />
                  </div>

                  <div className="p-4 space-y-3">
                    {/* Educational Disclaimer */}
                    <div className="p-3 bg-blue-50 border border-blue-200 rounded-2xl flex items-start gap-2.5">
                      <ShieldCheck className="w-5 h-5 text-blue-600 shrink-0 mt-0.5" />
                      <p className="text-[11px] text-blue-800 leading-relaxed">
                        This information is for educational purposes only and does not replace advice from a doctor or pharmacist. Consult a healthcare professional before starting, stopping, or changing a medicine.
                      </p>
                    </div>

                    {/* Search */}
                    <div className="relative">
                      <Search className="w-4 h-4 text-slate-400 absolute left-3 top-3" />
                      <input
                        type="text"
                        placeholder="Search medicines..."
                        value={infoSearch}
                        onChange={(e) => setInfoSearch(e.target.value)}
                        className="w-full pl-9 pr-3 py-2 bg-white border border-slate-200 rounded-xl text-xs font-medium"
                      />
                    </div>

                    {/* List */}
                    <div className="space-y-2.5">
                      {medicineInfos
                        .filter(
                          (inf) =>
                            inf.name.toLowerCase().includes(infoSearch.toLowerCase()) ||
                            inf.genericName.toLowerCase().includes(infoSearch.toLowerCase())
                        )
                        .map((inf) => (
                          <div
                            key={inf.id}
                            onClick={() => {
                              setSelectedInfo(inf);
                              setActiveScreen('medicine_info_details');
                            }}
                            className="p-4 bg-white rounded-2xl border border-slate-200 hover:border-teal-400 cursor-pointer transition shadow-xs flex items-center justify-between"
                          >
                            <div className="pr-2">
                              <div className="flex items-center gap-2">
                                <h4 className="font-bold text-slate-900 text-sm">{inf.name}</h4>
                                <span className="text-[10px] px-1.5 py-0.5 bg-slate-100 text-slate-600 rounded">
                                  {inf.type}
                                </span>
                              </div>
                              <p className="text-xs text-slate-500 italic">{inf.genericName}</p>
                              <p className="text-xs text-slate-600 line-clamp-1 mt-1">
                                {inf.shortDescription}
                              </p>
                            </div>
                            <ChevronRight className="w-4 h-4 text-slate-400 shrink-0" />
                          </div>
                        ))}
                    </div>
                  </div>
                </div>
              ) : activeScreen === 'medicine_info_details' && selectedInfo ? (
                /* MEDICINE INFO DETAILS */
                <div className="flex-1 flex flex-col bg-slate-50 overflow-y-auto">
                  <div className="p-4 bg-white border-b border-slate-200 flex items-center justify-between sticky top-0 z-10">
                    <button
                      onClick={() => setActiveScreen('medicine_info_list')}
                      className="p-1.5 -ml-1 text-slate-600 hover:text-slate-900 rounded-lg"
                    >
                      <ArrowLeft className="w-5 h-5" />
                    </button>
                    <h2 className="font-bold text-base text-slate-900">{selectedInfo.name}</h2>
                    <div className="w-8" />
                  </div>

                  <div className="p-4 space-y-4">
                    {/* Header info */}
                    <div className="bg-teal-50 border border-teal-200 p-4 rounded-2xl">
                      <h1 className="text-xl font-black text-teal-950">{selectedInfo.name}</h1>
                      <p className="text-xs text-teal-700 italic">
                        Generic: {selectedInfo.genericName} • {selectedInfo.type}
                      </p>
                      <p className="text-xs text-slate-700 mt-2 leading-relaxed">
                        {selectedInfo.shortDescription}
                      </p>
                    </div>

                    <div className="bg-amber-50 border border-amber-200 p-3 rounded-xl flex items-start gap-2 text-amber-900 text-xs">
                      <AlertTriangle className="w-4 h-4 text-amber-600 shrink-0 mt-0.5" />
                      <span>
                        Disclaimer: Not personalized medical advice. Always confirm dosages with your prescribing doctor.
                      </span>
                    </div>

                    <div className="bg-white p-4 rounded-2xl border border-slate-200 space-y-3 text-xs">
                      <div>
                        <h3 className="font-bold text-slate-900 text-sm mb-1.5 text-teal-700">Common Uses</h3>
                        <ul className="list-disc pl-4 space-y-1 text-slate-600">
                          {selectedInfo.commonUses.map((u, i) => (
                            <li key={i}>{u}</li>
                          ))}
                        </ul>
                      </div>

                      <div className="pt-2 border-t border-slate-100">
                        <h3 className="font-bold text-slate-900 text-sm mb-1 text-teal-700">General Dosage</h3>
                        <p className="text-slate-600 leading-relaxed">{selectedInfo.dosageInfo}</p>
                      </div>

                      <div className="pt-2 border-t border-slate-100">
                        <h3 className="font-bold text-red-600 text-sm mb-1.5">Important Warnings</h3>
                        <ul className="list-disc pl-4 space-y-1 text-red-700">
                          {selectedInfo.warnings.map((w, i) => (
                            <li key={i}>{w}</li>
                          ))}
                        </ul>
                      </div>

                      <div className="pt-2 border-t border-slate-100">
                        <h3 className="font-bold text-slate-900 text-sm mb-1 text-teal-700">Common Side Effects</h3>
                        <ul className="list-disc pl-4 space-y-1 text-slate-600">
                          {selectedInfo.sideEffects.map((s, i) => (
                            <li key={i}>{s}</li>
                          ))}
                        </ul>
                      </div>

                      <div className="pt-2 border-t border-slate-100">
                        <h3 className="font-bold text-slate-900 text-sm mb-1 text-teal-700">Precautions</h3>
                        <ul className="list-disc pl-4 space-y-1 text-slate-600">
                          {selectedInfo.precautions.map((p, i) => (
                            <li key={i}>{p}</li>
                          ))}
                        </ul>
                      </div>

                      <div className="pt-2 border-t border-slate-100">
                        <h3 className="font-bold text-slate-900 text-sm mb-1 text-teal-700">Storage Information</h3>
                        <p className="text-slate-600 leading-relaxed">{selectedInfo.storageInfo}</p>
                      </div>
                    </div>
                  </div>
                </div>
              ) : activeScreen === 'edit_profile' ? (
                /* EDIT PROFILE SCREEN */
                <div className="flex-1 flex flex-col bg-slate-50 overflow-y-auto">
                  <div className="p-4 bg-white border-b border-slate-200 flex items-center justify-between sticky top-0 z-10">
                    <button
                      onClick={() => setActiveScreen('main')}
                      className="p-1.5 -ml-1 text-slate-600 hover:text-slate-900 rounded-lg"
                    >
                      <ArrowLeft className="w-5 h-5" />
                    </button>
                    <h2 className="font-bold text-base text-slate-900">Edit Profile</h2>
                    <div className="w-8" />
                  </div>

                  <div className="p-5 space-y-4">
                    <div className="flex flex-col items-center">
                      <div className="w-20 h-20 rounded-full bg-teal-100 text-teal-700 font-extrabold text-2xl flex items-center justify-center border-2 border-teal-500 shadow-sm">
                        {userProfile.name[0] || 'U'}
                      </div>
                      <p className="text-xs text-teal-600 font-semibold mt-2">Change Avatar</p>
                    </div>

                    <div className="space-y-3 bg-white p-4 rounded-2xl border border-slate-200 text-xs">
                      <div>
                        <label className="block font-semibold text-slate-700 mb-1">Full Name</label>
                        <input
                          type="text"
                          value={userProfile.name}
                          onChange={(e) => setUserProfile({ ...userProfile, name: e.target.value })}
                          className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl font-medium"
                        />
                      </div>
                      <div>
                        <label className="block font-semibold text-slate-700 mb-1">Email</label>
                        <input
                          type="email"
                          value={userProfile.email}
                          onChange={(e) => setUserProfile({ ...userProfile, email: e.target.value })}
                          className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl font-medium"
                        />
                      </div>
                      <div>
                        <label className="block font-semibold text-slate-700 mb-1">Phone Number</label>
                        <input
                          type="tel"
                          value={userProfile.phone}
                          onChange={(e) => setUserProfile({ ...userProfile, phone: e.target.value })}
                          className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl font-medium"
                        />
                      </div>
                      <div>
                        <label className="block font-semibold text-slate-700 mb-1">Date of Birth</label>
                        <input
                          type="date"
                          value={userProfile.dob}
                          onChange={(e) => setUserProfile({ ...userProfile, dob: e.target.value })}
                          className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl font-medium"
                        />
                      </div>
                    </div>

                    <button
                      onClick={() => setActiveScreen('main')}
                      className="w-full py-3 bg-teal-600 text-white rounded-xl font-bold text-sm shadow-sm"
                    >
                      Save Changes
                    </button>
                  </div>
                </div>
              ) : activeScreen === 'notification_settings' ? (
                /* NOTIFICATION SETTINGS SCREEN */
                <div className="flex-1 flex flex-col bg-slate-50 overflow-y-auto">
                  <div className="p-4 bg-white border-b border-slate-200 flex items-center justify-between sticky top-0 z-10">
                    <button
                      onClick={() => setActiveScreen('main')}
                      className="p-1.5 -ml-1 text-slate-600 hover:text-slate-900 rounded-lg"
                    >
                      <ArrowLeft className="w-5 h-5" />
                    </button>
                    <h2 className="font-bold text-base text-slate-900">Notification Settings</h2>
                    <div className="w-8" />
                  </div>

                  <div className="p-4 space-y-3">
                    <div className="bg-white rounded-2xl border border-slate-200 divide-y divide-slate-100 text-xs">
                      <div className="p-3.5 flex items-center justify-between">
                        <div>
                          <p className="font-bold text-slate-900">Medication Reminders</p>
                          <p className="text-slate-500">Alerts when doses are due</p>
                        </div>
                        <input
                          type="checkbox"
                          checked={notificationToggles.medicationReminders}
                          onChange={(e) =>
                            setNotificationToggles({ ...notificationToggles, medicationReminders: e.target.checked })
                          }
                          className="w-4 h-4 text-teal-600 rounded"
                        />
                      </div>

                      <div className="p-3.5 flex items-center justify-between">
                        <div>
                          <p className="font-bold text-slate-900">Reminder Sound</p>
                          <p className="text-slate-500">Play pleasant medical tone</p>
                        </div>
                        <input
                          type="checkbox"
                          checked={notificationToggles.reminderSound}
                          onChange={(e) =>
                            setNotificationToggles({ ...notificationToggles, reminderSound: e.target.checked })
                          }
                          className="w-4 h-4 text-teal-600 rounded"
                        />
                      </div>

                      <div className="p-3.5 flex items-center justify-between">
                        <div>
                          <p className="font-bold text-slate-900">Vibration</p>
                          <p className="text-slate-500">Vibrate on alert</p>
                        </div>
                        <input
                          type="checkbox"
                          checked={notificationToggles.vibration}
                          onChange={(e) =>
                            setNotificationToggles({ ...notificationToggles, vibration: e.target.checked })
                          }
                          className="w-4 h-4 text-teal-600 rounded"
                        />
                      </div>

                      <div className="p-3.5 flex items-center justify-between">
                        <div>
                          <p className="font-bold text-slate-900">Daily Summary</p>
                          <p className="text-slate-500">Morning briefing of your pills</p>
                        </div>
                        <input
                          type="checkbox"
                          checked={notificationToggles.dailySummary}
                          onChange={(e) =>
                            setNotificationToggles({ ...notificationToggles, dailySummary: e.target.checked })
                          }
                          className="w-4 h-4 text-teal-600 rounded"
                        />
                      </div>

                      <div className="p-3.5 flex items-center justify-between">
                        <div>
                          <p className="font-bold text-slate-900">Missed Medication Alerts</p>
                          <p className="text-slate-500">Follow-up 30 minutes later</p>
                        </div>
                        <input
                          type="checkbox"
                          checked={notificationToggles.missedMedicationAlerts}
                          onChange={(e) =>
                            setNotificationToggles({ ...notificationToggles, missedMedicationAlerts: e.target.checked })
                          }
                          className="w-4 h-4 text-teal-600 rounded"
                        />
                      </div>
                    </div>
                  </div>
                </div>
              ) : (
                /* MAIN 4 BOTTOM TABS */
                <div className="flex-1 flex flex-col overflow-y-auto">
                  {/* TAB 0: HOME DASHBOARD */}
                  {currentTab === 0 && (
                    <div className="p-5 space-y-5">
                      {/* Top greeting */}
                      <div className="flex items-center justify-between">
                        <div>
                          <h1 className="text-xl font-black text-slate-900 tracking-tight">
                            Good Morning, {userProfile.name.split(' ')[0]}
                          </h1>
                          <p className="text-xs text-slate-500 font-medium">
                            Stay on track with your medicines.
                          </p>
                          <div className="flex items-center gap-1.5 text-xs text-teal-700 font-bold mt-1">
                            <Calendar className="w-3.5 h-3.5" />
                            <span>Sunday, September 27</span>
                          </div>
                        </div>
                        <button
                          onClick={() => {
                            setCurrentTab(3);
                            setActiveScreen('notification_settings');
                          }}
                          className="w-9 h-9 rounded-full bg-slate-100 text-slate-600 flex items-center justify-center hover:bg-slate-200 transition"
                        >
                          <Bell className="w-4 h-4" />
                        </button>
                      </div>

                      {/* Today's Progress Card */}
                      <div className="bg-gradient-to-r from-teal-600 to-teal-800 text-white p-5 rounded-3xl shadow-md">
                        <div className="flex items-center justify-between mb-2">
                          <h3 className="font-bold text-base">Today's Progress</h3>
                          <span className="px-2.5 py-0.5 bg-white/20 rounded-full text-xs font-black">
                            {progressPercent}%
                          </span>
                        </div>
                        <p className="text-xs text-teal-100/90 mb-3">
                          {todayTaken} of {todayTotal} medicines taken
                        </p>
                        <div className="w-full h-2.5 bg-teal-950/40 rounded-full overflow-hidden">
                          <div
                            className="h-full bg-white rounded-full transition-all duration-500 shadow-sm"
                            style={{ width: `${progressPercent}%` }}
                          />
                        </div>
                      </div>

                      {/* Next Reminder Card */}
                      {nextReminder && (
                        <div className="p-4 bg-teal-50 border border-teal-200/80 rounded-2xl flex items-center justify-between">
                          <div>
                            <div className="flex items-center gap-1.5 text-teal-800 font-bold text-xs mb-1">
                              <Clock className="w-3.5 h-3.5" />
                              <span>Next Reminder • {nextReminder.time}</span>
                            </div>
                            <h4 className="font-extrabold text-slate-900 text-base">
                              {nextReminder.medicineName}
                            </h4>
                            <p className="text-xs text-slate-600">{nextReminder.dosage} • In 2 hrs 15 mins</p>
                          </div>
                          <button
                            onClick={() => {
                              setSelectedMedicineId(nextReminder.medicineId);
                              setActiveScreen('medicine_details');
                            }}
                            className="px-3 py-1.5 bg-white border border-teal-300 text-teal-700 rounded-xl text-xs font-bold hover:bg-teal-50 shadow-2xs"
                          >
                            View Details
                          </button>
                        </div>
                      )}

                      {/* Quick Actions Grid */}
                      <div>
                        <h3 className="text-sm font-bold text-slate-900 mb-2.5">Quick Actions</h3>
                        <div className="grid grid-cols-2 gap-2.5">
                          <button
                            onClick={() => openAddMedicine()}
                            className="p-3 bg-teal-50 hover:bg-teal-100/80 border border-teal-200 rounded-2xl flex items-center gap-2.5 text-left transition"
                          >
                            <div className="w-8 h-8 rounded-xl bg-teal-600 text-white flex items-center justify-center shrink-0">
                              <Plus className="w-4 h-4" />
                            </div>
                            <div>
                              <p className="text-xs font-bold text-teal-900">Add Medicine</p>
                              <p className="text-[10px] text-teal-700">Set new schedule</p>
                            </div>
                          </button>

                          <button
                            onClick={() => setCurrentTab(1)}
                            className="p-3 bg-sky-50 hover:bg-sky-100/80 border border-sky-200 rounded-2xl flex items-center gap-2.5 text-left transition"
                          >
                            <div className="w-8 h-8 rounded-xl bg-sky-600 text-white flex items-center justify-center shrink-0">
                              <Pill className="w-4 h-4" />
                            </div>
                            <div>
                              <p className="text-xs font-bold text-sky-900">Medicines</p>
                              <p className="text-[10px] text-sky-700">Active inventory</p>
                            </div>
                          </button>

                          <button
                            onClick={() => setActiveScreen('medicine_info_list')}
                            className="p-3 bg-purple-50 hover:bg-purple-100/80 border border-purple-200 rounded-2xl flex items-center gap-2.5 text-left transition"
                          >
                            <div className="w-8 h-8 rounded-xl bg-purple-600 text-white flex items-center justify-center shrink-0">
                              <ShieldCheck className="w-4 h-4" />
                            </div>
                            <div>
                              <p className="text-xs font-bold text-purple-900">Medicine Info</p>
                              <p className="text-[10px] text-purple-700">Drug guide & uses</p>
                            </div>
                          </button>

                          <button
                            onClick={() => setCurrentTab(2)}
                            className="p-3 bg-amber-50 hover:bg-amber-100/80 border border-amber-200 rounded-2xl flex items-center gap-2.5 text-left transition"
                          >
                            <div className="w-8 h-8 rounded-xl bg-amber-600 text-white flex items-center justify-center shrink-0">
                              <Clock className="w-4 h-4" />
                            </div>
                            <div>
                              <p className="text-xs font-bold text-amber-900">History</p>
                              <p className="text-[10px] text-amber-700">Adherence tracking</p>
                            </div>
                          </button>
                        </div>
                      </div>

                      {/* Today's Medicines list */}
                      <div>
                        <div className="flex items-center justify-between mb-2.5">
                          <h3 className="text-sm font-bold text-slate-900">Today's Medicines</h3>
                          <span className="text-xs font-medium text-slate-500">
                            {todayTaken}/{todayTotal} Done
                          </span>
                        </div>

                        <div className="space-y-2.5">
                          {reminders.map((item) => (
                            <div
                              key={item.id}
                              className={`p-3.5 rounded-2xl border transition-all ${
                                item.isTaken
                                  ? 'bg-slate-50/70 border-slate-200'
                                  : item.isSkipped
                                  ? 'bg-red-50/50 border-red-200'
                                  : 'bg-white border-slate-200 shadow-xs'
                              } flex items-center justify-between`}
                            >
                              <div className="flex items-center gap-3">
                                <div
                                  className={`w-12 h-12 rounded-xl flex flex-col items-center justify-center text-center font-bold ${
                                    item.isTaken
                                      ? 'bg-emerald-100 text-emerald-800'
                                      : item.isSkipped
                                      ? 'bg-red-100 text-red-800'
                                      : 'bg-teal-50 text-teal-700'
                                  }`}
                                >
                                  <span className="text-[11px] leading-tight">{item.time.split(' ')[0]}</span>
                                  <span className="text-[9px] uppercase">{item.time.split(' ')[1]}</span>
                                </div>

                                <div>
                                  <h4
                                    className={`text-sm font-extrabold ${
                                      item.isTaken ? 'line-through text-slate-400' : 'text-slate-900'
                                    }`}
                                  >
                                    {item.medicineName}
                                  </h4>
                                  <p className="text-xs text-slate-500">{item.dosage}</p>
                                  {item.snoozedUntil && (
                                    <p className="text-[10px] text-amber-600 font-bold">{item.snoozedUntil}</p>
                                  )}
                                </div>
                              </div>

                              <div>
                                {item.isTaken ? (
                                  <span className="inline-flex items-center gap-1 px-3 py-1.5 bg-emerald-50 text-emerald-700 border border-emerald-200 rounded-xl text-xs font-bold">
                                    <CheckCircle2 className="w-3.5 h-3.5" /> Taken
                                  </span>
                                ) : item.isSkipped ? (
                                  <span className="inline-flex items-center gap-1 px-3 py-1.5 bg-red-50 text-red-700 border border-red-200 rounded-xl text-xs font-bold">
                                    <XCircle className="w-3.5 h-3.5" /> Skipped
                                  </span>
                                ) : (
                                  <div className="flex items-center gap-1.5">
                                    <button
                                      onClick={() => setSnoozeModalReminder(item)}
                                      className="p-2 text-slate-400 hover:text-amber-600 hover:bg-amber-50 rounded-xl transition"
                                      title="Snooze"
                                    >
                                      <Clock className="w-4 h-4" />
                                    </button>
                                    <button
                                      onClick={() => handleMarkAsSkipped(item.medicineId, item.time)}
                                      className="p-2 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-xl transition"
                                      title="Skip"
                                    >
                                      <XCircle className="w-4 h-4" />
                                    </button>
                                    <button
                                      onClick={() => handleMarkAsTaken(item.medicineId, item.time)}
                                      className="px-3.5 py-1.5 bg-teal-600 hover:bg-teal-700 text-white rounded-xl text-xs font-bold shadow-xs transition active:scale-95"
                                    >
                                      Take
                                    </button>
                                  </div>
                                )}
                              </div>
                            </div>
                          ))}
                        </div>
                      </div>
                    </div>
                  )}

                  {/* TAB 1: MEDICINES SCREEN */}
                  {currentTab === 1 && (
                    <div className="p-4 space-y-4">
                      <div className="flex items-center justify-between">
                        <h2 className="text-xl font-black text-slate-900">My Medicines</h2>
                        <button
                          onClick={() => openAddMedicine()}
                          className="px-3 py-1.5 bg-teal-600 text-white rounded-xl text-xs font-bold flex items-center gap-1 shadow-xs"
                        >
                          <Plus className="w-3.5 h-3.5" /> Add
                        </button>
                      </div>

                      {/* Search Bar */}
                      <div className="relative">
                        <Search className="w-4 h-4 text-slate-400 absolute left-3 top-3" />
                        <input
                          type="text"
                          placeholder="Search medicines..."
                          value={medSearch}
                          onChange={(e) => setMedSearch(e.target.value)}
                          className="w-full pl-9 pr-3 py-2 bg-slate-100 border border-slate-200 rounded-xl text-xs font-medium focus:outline-none focus:border-teal-500"
                        />
                      </div>

                      {/* Filters */}
                      <div className="flex gap-1.5 overflow-x-auto pb-1 text-xs">
                        {(['All', 'Active', 'Paused', 'Completed'] as const).map((f) => (
                          <button
                            key={f}
                            onClick={() => setMedFilter(f)}
                            className={`px-3 py-1.5 rounded-full font-bold transition ${
                              medFilter === f
                                ? 'bg-teal-600 text-white shadow-xs'
                                : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
                            }`}
                          >
                            {f}
                          </button>
                        ))}
                      </div>

                      {/* Medicine Cards list */}
                      {filteredMedicines.length === 0 ? (
                        <div className="p-8 text-center bg-slate-50 rounded-2xl border border-slate-200 space-y-2 mt-4">
                          <Pill className="w-10 h-10 text-slate-400 mx-auto" />
                          <h4 className="font-bold text-slate-800 text-sm">No medicines found</h4>
                          <p className="text-xs text-slate-500">
                            {medSearch ? 'Try a different search query' : 'Start by adding your first medicine'}
                          </p>
                          {!medSearch && (
                            <button
                              onClick={() => openAddMedicine()}
                              className="mt-2 px-4 py-2 bg-teal-600 text-white rounded-xl text-xs font-bold"
                            >
                              Add Your First Medicine
                            </button>
                          )}
                        </div>
                      ) : (
                        <div className="space-y-3">
                          {filteredMedicines.map((med) => (
                            <div
                              key={med.id}
                              className="p-4 bg-white rounded-2xl border border-slate-200 hover:border-teal-300 transition shadow-xs space-y-3"
                            >
                              <div className="flex items-start justify-between">
                                <div
                                  className="cursor-pointer"
                                  onClick={() => {
                                    setSelectedMedicineId(med.id);
                                    setActiveScreen('medicine_details');
                                  }}
                                >
                                  <div className="flex items-center gap-2">
                                    <h4 className="font-extrabold text-slate-900 text-base hover:text-teal-700">
                                      {med.name}
                                    </h4>
                                    <span
                                      className={`text-[10px] px-2 py-0.5 rounded-full font-bold ${
                                        med.isActive
                                          ? 'bg-emerald-50 text-emerald-700 border border-emerald-200'
                                          : 'bg-slate-100 text-slate-600'
                                      }`}
                                    >
                                      {med.isActive ? 'Active' : 'Paused'}
                                    </span>
                                  </div>
                                  {med.genericName && (
                                    <p className="text-xs text-slate-500 italic mt-0.5">{med.genericName}</p>
                                  )}
                                </div>
                              </div>

                              <div className="flex flex-wrap gap-1.5 text-[11px] text-slate-600">
                                <span className="px-2 py-0.5 bg-slate-100 rounded-md font-medium">
                                  {med.type}
                                </span>
                                <span className="px-2 py-0.5 bg-slate-100 rounded-md font-medium">
                                  {med.strength}
                                </span>
                                <span className="px-2 py-0.5 bg-slate-100 rounded-md font-medium">
                                  {med.dosage}
                                </span>
                                <span className="px-2 py-0.5 bg-teal-50 text-teal-800 rounded-md font-bold">
                                  {med.frequency}
                                </span>
                              </div>

                              <div className="pt-2 border-t border-slate-100 flex items-center justify-between text-xs">
                                <span className="text-slate-500 font-medium">
                                  Next: {med.reminderTimes[0] || 'N/A'}
                                </span>
                                <div className="flex items-center gap-2">
                                  <button
                                    onClick={() => handleToggleMedicineActive(med.id)}
                                    className="text-slate-600 hover:text-slate-900 font-semibold text-[11px]"
                                  >
                                    {med.isActive ? 'Pause' : 'Resume'}
                                  </button>
                                  <button
                                    onClick={() => openAddMedicine(med)}
                                    className="text-teal-600 hover:text-teal-800 font-semibold text-[11px]"
                                  >
                                    Edit
                                  </button>
                                  <button
                                    onClick={() => setDeleteConfirmMed(med)}
                                    className="text-red-500 hover:text-red-700"
                                  >
                                    <Trash2 className="w-3.5 h-3.5" />
                                  </button>
                                </div>
                              </div>
                            </div>
                          ))}
                        </div>
                      )}
                    </div>
                  )}

                  {/* TAB 2: HISTORY SCREEN */}
                  {currentTab === 2 && (
                    <div className="p-4 space-y-4">
                      <div className="flex items-center justify-between">
                        <h2 className="text-xl font-black text-slate-900">Medication History</h2>
                      </div>

                      {/* Filter pills */}
                      <div className="flex gap-2 text-xs">
                        {(['Today', 'This Week', 'This Month'] as const).map((filter) => (
                          <button
                            key={filter}
                            onClick={() => setHistoryFilter(filter)}
                            className={`px-3 py-1.5 rounded-full font-bold transition ${
                              historyFilter === filter
                                ? 'bg-teal-600 text-white shadow-xs'
                                : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
                            }`}
                          >
                            {filter}
                          </button>
                        ))}
                      </div>

                      {/* Adherence Summary Card */}
                      <div className="p-4 bg-white rounded-2xl border border-slate-200 flex items-center justify-between shadow-xs">
                        <div className="flex items-center gap-3">
                          <div className="w-12 h-12 rounded-full bg-emerald-100 text-emerald-700 font-black text-base flex items-center justify-center">
                            88%
                          </div>
                          <div>
                            <h4 className="font-bold text-slate-900 text-sm">Adherence Summary</h4>
                            <p className="text-xs text-slate-500">7 taken, 1 skipped in this period</p>
                          </div>
                        </div>
                        <span className="px-2.5 py-1 bg-emerald-50 text-emerald-700 border border-emerald-200 rounded-full text-xs font-bold">
                          On Track
                        </span>
                      </div>

                      {/* Medication Log entries */}
                      <div className="space-y-2">
                        {medicationLogs.map((log) => (
                          <div
                            key={log.id}
                            className="p-3 bg-white rounded-xl border border-slate-200 flex items-center justify-between text-xs"
                          >
                            <div className="flex items-center gap-2.5">
                              {log.status === 'taken' ? (
                                <CheckCircle2 className="w-5 h-5 text-emerald-600 shrink-0" />
                              ) : log.status === 'skipped' ? (
                                <XCircle className="w-5 h-5 text-red-500 shrink-0" />
                              ) : (
                                <Clock className="w-5 h-5 text-slate-400 shrink-0" />
                              )}
                              <div>
                                <h5 className="font-bold text-slate-900">{log.medicineName}</h5>
                                <p className="text-[11px] text-slate-500">
                                  {log.dosage} • Scheduled: {log.scheduledTime}
                                </p>
                                {log.actualTime && (
                                  <p className="text-[10px] text-teal-600 font-medium">
                                    Logged at {log.actualTime}
                                  </p>
                                )}
                              </div>
                            </div>
                            <span
                              className={`px-2 py-0.5 rounded text-[11px] font-bold ${
                                log.status === 'taken'
                                  ? 'bg-emerald-50 text-emerald-700'
                                  : log.status === 'skipped'
                                  ? 'bg-red-50 text-red-700'
                                  : 'bg-slate-100 text-slate-600'
                              }`}
                            >
                              {log.status === 'taken' ? 'Taken ✓' : log.status === 'skipped' ? 'Skipped' : 'Upcoming'}
                            </span>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}

                  {/* TAB 3: PROFILE SCREEN */}
                  {currentTab === 3 && (
                    <div className="p-4 space-y-4">
                      {/* Top Profile Card */}
                      <div className="p-4 bg-white rounded-2xl border border-slate-200 flex items-center justify-between shadow-xs">
                        <div className="flex items-center gap-3">
                          <div className="w-14 h-14 rounded-full bg-teal-100 text-teal-700 font-black text-xl flex items-center justify-center">
                            {userProfile.name[0] || 'U'}
                          </div>
                          <div>
                            <h3 className="font-extrabold text-slate-900 text-base">{userProfile.name}</h3>
                            <p className="text-xs text-slate-500">{userProfile.email}</p>
                          </div>
                        </div>
                        <button
                          onClick={() => setActiveScreen('edit_profile')}
                          className="px-3 py-1.5 border border-teal-500 text-teal-700 rounded-xl text-xs font-bold hover:bg-teal-50"
                        >
                          Edit
                        </button>
                      </div>

                      {/* Personal Info group */}
                      <div className="bg-white rounded-2xl border border-slate-200 divide-y divide-slate-100 text-xs">
                        <div className="p-3 font-bold text-slate-900 bg-slate-50/50 rounded-t-2xl">
                          Personal Information
                        </div>
                        <div className="p-3 flex justify-between">
                          <span className="text-slate-500">Phone</span>
                          <span className="font-semibold text-slate-800">{userProfile.phone}</span>
                        </div>
                        <div className="p-3 flex justify-between">
                          <span className="text-slate-500">Date of Birth</span>
                          <span className="font-semibold text-slate-800">{userProfile.dob}</span>
                        </div>
                      </div>

                      {/* App & Health Settings */}
                      <div className="bg-white rounded-2xl border border-slate-200 divide-y divide-slate-100 text-xs">
                        <div className="p-3 font-bold text-slate-900 bg-slate-50/50 rounded-t-2xl">
                          Preferences & Settings
                        </div>
                        <button
                          onClick={() => setActiveScreen('notification_settings')}
                          className="w-full p-3 flex items-center justify-between text-left hover:bg-slate-50 transition"
                        >
                          <span className="font-medium text-slate-700">Notification Settings</span>
                          <ChevronRight className="w-4 h-4 text-slate-400" />
                        </button>
                        <div className="p-3 flex items-center justify-between">
                          <span className="font-medium text-slate-700">Dark Mode</span>
                          <input
                            type="checkbox"
                            checked={isDarkMode}
                            onChange={(e) => setIsDarkMode(e.target.checked)}
                            className="w-4 h-4 text-teal-600 rounded"
                          />
                        </div>
                        <button
                          onClick={() => setActiveScreen('medicine_info_list')}
                          className="w-full p-3 flex items-center justify-between text-left hover:bg-slate-50 transition"
                        >
                          <span className="font-medium text-slate-700">Educational Drug Guide</span>
                          <ChevronRight className="w-4 h-4 text-slate-400" />
                        </button>
                      </div>

                      {/* Account & Support */}
                      <div className="bg-white rounded-2xl border border-slate-200 divide-y divide-slate-100 text-xs">
                        <div className="p-3 font-bold text-slate-900 bg-slate-50/50 rounded-t-2xl">
                          Account Actions
                        </div>
                        <button
                          onClick={() => setShowLogoutConfirm(true)}
                          className="w-full p-3 text-left font-bold text-red-600 hover:bg-red-50 flex items-center justify-between transition"
                        >
                          <span>Logout</span>
                          <ChevronRight className="w-4 h-4 text-red-400" />
                        </button>
                      </div>
                    </div>
                  )}
                </div>
              )}
            </div>

            {/* Native 5-Destination Material NavigationBar */}
            {isLoggedIn && activeScreen === 'main' && (
              <div className="h-16 bg-white border-t border-slate-200 flex items-center justify-around px-2 select-none z-20">
                <button
                  onClick={() => setCurrentTab(0)}
                  className={`flex flex-col items-center gap-1 transition ${
                    currentTab === 0 ? 'text-teal-600' : 'text-slate-400 hover:text-slate-600'
                  }`}
                >
                  <Clock className="w-5 h-5" />
                  <span className="text-[10px] font-bold">Home</span>
                </button>

                <button
                  onClick={() => setCurrentTab(1)}
                  className={`flex flex-col items-center gap-1 transition ${
                    currentTab === 1 ? 'text-teal-600' : 'text-slate-400 hover:text-slate-600'
                  }`}
                >
                  <Pill className="w-5 h-5" />
                  <span className="text-[10px] font-bold">Medicines</span>
                </button>

                {/* Center visually elevated Add Button */}
                <button
                  onClick={() => openAddMedicine()}
                  className="w-12 h-12 -mt-5 bg-teal-600 text-white rounded-full flex items-center justify-center shadow-lg shadow-teal-600/30 hover:bg-teal-700 active:scale-95 transition"
                  title="Add Medicine"
                >
                  <Plus className="w-6 h-6" />
                </button>

                <button
                  onClick={() => setCurrentTab(2)}
                  className={`flex flex-col items-center gap-1 transition ${
                    currentTab === 2 ? 'text-teal-600' : 'text-slate-400 hover:text-slate-600'
                  }`}
                >
                  <Calendar className="w-5 h-5" />
                  <span className="text-[10px] font-bold">History</span>
                </button>

                <button
                  onClick={() => setCurrentTab(3)}
                  className={`flex flex-col items-center gap-1 transition ${
                    currentTab === 3 ? 'text-teal-600' : 'text-slate-400 hover:text-slate-600'
                  }`}
                >
                  <UserIcon className="w-5 h-5" />
                  <span className="text-[10px] font-bold">Profile</span>
                </button>
              </div>
            )}

            {/* Bottom Gesture Bar */}
            {deviceFrame && (
              <div className="h-4 bg-slate-900 flex items-center justify-center">
                <div className="w-28 h-1 bg-white/40 rounded-full" />
              </div>
            )}
          </div>
        </main>

        {/* Flutter Source Code Inspector Drawer */}
        {showCodeInspector && (
          <aside className="w-96 bg-slate-900 border-l border-slate-800 text-slate-200 flex flex-col h-[calc(100vh-60px)] shadow-2xl z-40">
            <div className="p-3 bg-slate-800 border-b border-slate-700 flex items-center justify-between">
              <div className="flex items-center gap-2">
                <FileCode className="w-4 h-4 text-teal-400" />
                <span className="font-bold text-xs text-white">Flutter Native Project Explorer</span>
              </div>
              <button
                onClick={() => setShowCodeInspector(false)}
                className="text-slate-400 hover:text-white text-xs px-2 py-1 rounded"
              >
                ✕
              </button>
            </div>

            {/* File tabs */}
            <div className="p-2 border-b border-slate-800 flex gap-1 overflow-x-auto text-[11px]">
              {Object.keys(dartCodeSnippets).map((fn) => (
                <button
                  key={fn}
                  onClick={() => setSelectedDartFile(fn)}
                  className={`px-2.5 py-1 rounded-md shrink-0 font-mono transition ${
                    selectedDartFile === fn ? 'bg-teal-600 text-white font-bold' : 'bg-slate-800 text-slate-400 hover:text-slate-200'
                  }`}
                >
                  {fn.split('/').pop()}
                </button>
              ))}
            </div>

            {/* Code Snippet Box */}
            <div className="flex-1 p-3 overflow-y-auto font-mono text-xs leading-relaxed bg-slate-950 text-teal-300">
              <div className="text-slate-500 mb-2">// File: {selectedDartFile}</div>
              <pre className="whitespace-pre-wrap">{dartCodeSnippets[selectedDartFile]}</pre>
            </div>

            {/* Build commands helper */}
            <div className="p-3 bg-slate-850 border-t border-slate-800 text-xs text-slate-300 space-y-1">
              <p className="font-bold text-white text-[11px]">Terminal Commands for this project:</p>
              <div className="bg-slate-950 p-2 rounded border border-slate-800 font-mono text-[11px] text-emerald-400">
                flutter run<br />
                flutter build apk --release
              </div>
            </div>
          </aside>
        )}
      </div>

      {/* Snooze Modal */}
      {snoozeModalReminder && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl p-5 max-w-xs w-full shadow-2xl space-y-4">
            <h3 className="font-bold text-slate-900 text-base">Snooze Reminder</h3>
            <p className="text-xs text-slate-500">
              Delay alert for <span className="font-bold text-slate-800">{snoozeModalReminder.medicineName}</span>:
            </p>
            <div className="space-y-2">
              <button
                onClick={() => handleSnooze(snoozeModalReminder, 10)}
                className="w-full py-2 bg-slate-100 hover:bg-teal-50 hover:text-teal-700 text-slate-700 rounded-xl text-xs font-bold transition"
              >
                10 Minutes
              </button>
              <button
                onClick={() => handleSnooze(snoozeModalReminder, 30)}
                className="w-full py-2 bg-slate-100 hover:bg-teal-50 hover:text-teal-700 text-slate-700 rounded-xl text-xs font-bold transition"
              >
                30 Minutes
              </button>
              <button
                onClick={() => handleSnooze(snoozeModalReminder, 60)}
                className="w-full py-2 bg-slate-100 hover:bg-teal-50 hover:text-teal-700 text-slate-700 rounded-xl text-xs font-bold transition"
              >
                1 Hour
              </button>
            </div>
            <button
              onClick={() => setSnoozeModalReminder(null)}
              className="w-full py-2 text-slate-400 text-xs font-bold"
            >
              Cancel
            </button>
          </div>
        </div>
      )}

      {/* Delete Confirmation Dialog */}
      {deleteConfirmMed && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl p-5 max-w-xs w-full shadow-2xl space-y-3">
            <h3 className="font-bold text-slate-900 text-base">Delete this medicine?</h3>
            <p className="text-xs text-slate-500 leading-relaxed">
              This will remove "{deleteConfirmMed.name}" and all its scheduled reminders and logs.
            </p>
            <div className="flex gap-2 pt-2">
              <button
                onClick={() => setDeleteConfirmMed(null)}
                className="flex-1 py-2 bg-slate-100 text-slate-700 rounded-xl text-xs font-bold"
              >
                Cancel
              </button>
              <button
                onClick={() => handleDeleteMedicine(deleteConfirmMed.id)}
                className="flex-1 py-2 bg-red-600 text-white rounded-xl text-xs font-bold"
              >
                Delete
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Logout Confirmation Dialog */}
      {showLogoutConfirm && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl p-5 max-w-xs w-full shadow-2xl space-y-3">
            <h3 className="font-bold text-slate-900 text-base">Log Out?</h3>
            <p className="text-xs text-slate-500 leading-relaxed">
              Are you sure you want to log out of MediCare?
            </p>
            <div className="flex gap-2 pt-2">
              <button
                onClick={() => setShowLogoutConfirm(false)}
                className="flex-1 py-2 bg-slate-100 text-slate-700 rounded-xl text-xs font-bold"
              >
                Cancel
              </button>
              <button
                onClick={() => {
                  setShowLogoutConfirm(false);
                  setIsLoggedIn(false);
                  setAuthView('welcome');
                }}
                className="flex-1 py-2 bg-red-600 text-white rounded-xl text-xs font-bold"
              >
                Log Out
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
