import 'package:flutter/material.dart';
import 'package:thai_address_picker/thai_address_picker.dart';

/// ตัวอย่างการใช้งานทั้งหมดรวมกัน
/// Example: Complete Integration with Multiple Features
///
/// ตัวอย่างนี้แสดงวิธีการใช้ thai_address_picker แบบครอบคลุมทั้งหมด:
/// - ThaiAddressForm
/// - ZipCodeAutocomplete
/// - VillageAutocomplete
/// - การแสดงผลข้อมูลที่เลือก
/// - State synchronization

class CompleteIntegrationExample extends ConsumerStatefulWidget {
  const CompleteIntegrationExample({super.key});

  @override
  ConsumerState<CompleteIntegrationExample> createState() =>
      _CompleteIntegrationExampleState();
}

class _CompleteIntegrationExampleState
    extends ConsumerState<CompleteIntegrationExample> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initAsync = ref.watch(repositoryInitProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Integration Example'),
        elevation: 0,
      ),
      body: initAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
        data: (_) => _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return PageView(
      controller: _pageController,
      onPageChanged: (page) {
        setState(() => _currentPage = page);
      },
      children: [
        _buildStep1(), // Form ที่อยู่
        _buildStep2(), // Zip Code Autocomplete
        _buildStep3(), // Village Autocomplete
        _buildStep4(), // Summary
      ],
    );
  }

  // ==================== Step 1: Address Form ====================

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            step: 1,
            title: '📋 กรอกที่อยู่',
            description: 'เลือกจังหวัด อำเภอ ตำบลไทยของคุณ',
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ThaiAddressForm(useThai: true),
            ),
          ),
          const SizedBox(height: 24),
          _buildNavigationButtons(
            onNext: () => _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Step 2: Zip Code Autocomplete ====================

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            step: 2,
            title: '📮 ค้นหาด้วยรหัสไปรษณีย์',
            description: 'พิมพ์รหัสไปรษณีย์เพื่อค้นหาที่อยู่อัตโนมัติ',
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ZipCodeAutocomplete(
                decoration: InputDecoration(
                  labelText: 'รหัสไปรษณีย์',
                  hintText: 'พิมพ์เช่น 10110',
                  prefixIcon: const Icon(Icons.mail),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '💡 Tips:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildTip('รหัสไปรษณีย์ไทยประกอบด้วย 5 หลัก'),
                _buildTip('ระบบจะค้นหาและเติมข้อมูลที่อยู่อัตโนมัติ'),
                _buildTip('บางรหัสมีหลายพื้นที่ - เลือกได้'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildNavigationButtons(
            onPrevious: () => _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
            onNext: () => _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Step 3: Village Autocomplete ====================

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            step: 3,
            title: '🏘️ ค้นหาหมู่บ้าน',
            description: 'ค้นหาหมู่บ้านที่ต้องการ พร้อมหมู่ที่ (Moo)',
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: VillageAutocomplete(
                decoration: InputDecoration(
                  labelText: 'หมู่บ้าน',
                  hintText: 'พิมพ์ชื่อหมู่บ้าน',
                  prefixIcon: const Icon(Icons.home),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '💡 Features:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildTip('ค้นหาจากตัวอักษรแรก'),
                _buildTip('รองรับการค้นหาด้วย substring'),
                _buildTip('แสดง Moo number (หมู่ที่) เพื่อความแม่นยำ'),
                _buildTip('~70,000 หมู่บ้านทั่วประเทศ'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildNavigationButtons(
            onPrevious: () => _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
            onNext: () => _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Step 4: Summary ====================

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            step: 4,
            title: '✅ สรุปข้อมูล',
            description: 'ตรวจสอบข้อมูลที่เลือก',
          ),
          const SizedBox(height: 16),
          Consumer(
            builder: (context, ref, _) {
              final state = ref.watch(thaiAddressNotifierProvider);
              final address = state.toThaiAddress();

              return Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryRow('จังหวัด', address.provinceTh),
                      _buildSummaryRow('Province', address.provinceEn),
                      const SizedBox(height: 8),
                      _buildSummaryRow('อำเภอ/เขต', address.districtTh),
                      _buildSummaryRow('District', address.districtEn),
                      const SizedBox(height: 8),
                      _buildSummaryRow('ตำบล/แขวง', address.subDistrictTh),
                      _buildSummaryRow('Sub-district', address.subDistrictEn),
                      const SizedBox(height: 8),
                      _buildSummaryRow('รหัสไปรษณีย์', address.zipCode),
                      if (address.lat != null)
                        _buildSummaryRow('ละติจูด', address.lat.toString()),
                      if (address.long != null)
                        _buildSummaryRow('ลองจิจูด', address.long.toString()),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          _buildNavigationButtons(
            onPrevious: () => _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Helper Widgets ====================

  Widget _buildStepHeader({
    required int step,
    required String title,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '$step',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: _currentPage / 3, minHeight: 4),
        ),
      ],
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Text('✓ ', style: TextStyle(color: Colors.green)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons({
    VoidCallback? onPrevious,
    VoidCallback? onNext,
  }) {
    return Row(
      children: [
        if (onPrevious != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onPrevious,
              icon: const Icon(Icons.arrow_back),
              label: const Text('ย้อนกลับ'),
            ),
          ),
        if (onPrevious != null && onNext != null) const SizedBox(width: 8),
        if (onNext != null)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('ต่อไป'),
            ),
          ),
        if (onPrevious == null && onNext == null)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                _pageController.jumpToPage(0);
              },
              icon: const Icon(Icons.home),
              label: const Text('กลับหน้าแรก'),
            ),
          ),
      ],
    );
  }
}
