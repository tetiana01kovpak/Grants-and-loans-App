import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';

const bridge = MethodChannel('grant_compass/device');

class Opportunity {
  const Opportunity(this.title, this.tag, this.status, this.funding, this.fit,
      this.eligibility, this.documents, this.url, {this.calendarDate});
  final String title, tag, status, funding, fit, eligibility, documents, url;
  final DateTime? calendarDate;
}

final allOpportunities = <Opportunity>[
  Opportunity('Baltic Marine Watchdog Challenge', 'Europe · Autonomous vessels',
      'Deadline: 2 December 2026, 14:00 local Swedish time.',
      'Up to €520,000 per team in two stages; pre-commercial procurement, not a conventional grant.',
      'Autonomous maritime surveillance and safe navigation. Your navigation technology could be relevant in a team, but yacht self-parking alone does not meet the full challenge requirements.',
      'A legal entity headquartered in the EU, EFTA or UK must submit. Incorporated companies must have at least 50% of equity held in those regions. Other exclusions apply.',
      'Submit the online form and mandatory Declaration of Honour. Support claims with scientific data or clearly labelled estimates; review all challenge documents.',
      'https://www.vinnova.se/en/calls-for-proposals/radikal-innovation/the-baltic-marine-watchdog-challenge/',
      calendarDate: DateTime.utc(2026, 12, 2, 13)),
  Opportunity('EIC STEP Scale Up', 'EU · Deep tech / AI',
      'Upcoming evaluation batch: 25 November 2026',
      '€10–30 million equity investment; this is not a grant.',
      'Scale-up of strategic digital technologies, clean technologies and biotechnology. AI and maritime projects may fit if they meet the strategic technology criteria.',
      'Eligible European startups, SMEs and small mid-caps; significant scale-up financing needs. Check the call for all conditions.',
      'The 2026 call requires a business plan (maximum 50 pages), pitch deck (maximum 15 pages), qualified investor pre-commitment using the official template, financial plan, freedom-to-operate analysis and CVs. Check the official call for details and updates.',
      'https://eic.ec.europa.eu/eic-funding-opportunities/step-scale_en',
      calendarDate: DateTime.utc(2026, 11, 25, 9)),
  const Opportunity('SEAS — blue economy SMEs', 'Croatia / Italy · Maritime',
      'First cut-off passed on 9 November 2026; further cut-offs are conditional and unconfirmed.',
      '€80,000–125,000 per project, up to 80% of eligible costs.',
      'Innovative blue-economy products and services. AI navigation and autonomous docking for sailing boats and yachts may fit if the project satisfies the call.',
      'SMEs or startups in eligible Croatia–Italy programme areas; at least one Croatian and one Italian entrepreneur, maximum three partners. Confirm current call status.',
      'Prepare a joint project proposal in English, partner and company details, budget and evidence of co-financing. Check the official guidelines for the required forms and declarations.',
      'https://cbchb.eu/seas-call-for-grant-applications-for-entrepreneurs-from-the-croatian-italian-cross-border-area-is-now-open/'),
  const Opportunity('Process innovation in S3 areas', 'Croatia · Innovation',
      'Listed among HAMAG-BICRO open calls; check the official page for current status and deadline.',
      'Check the current call documents for grant amounts and co-financing.',
      'Process innovation in Croatian smart specialisation areas. Verify that the proposed activity and sector are eligible.',
      'Check the call for applicant, location, size and S3 eligibility requirements.',
      'Prepare the official application form, project description, costed budget, company and financial records, and declarations. Verify the mandatory list in the call package.',
      'https://hamagbicro.hr/natjecaji/'),
  const Opportunity('Proof of innovative concept — first call', 'Croatia · Early-stage deep tech',
      'Listed among HAMAG-BICRO open calls; verify whether this listing is current.',
      'See the official call documents for amounts, co-financing and eligible costs.',
      'Early-stage proof of concept; potentially relevant to AI, marine devices and deep tech where the project meets call conditions.',
      'Verify applicant eligibility, technology readiness and eligible activities in the current call.',
      'Prepare a technical concept, development plan, budget, company or applicant details and official declarations. The call package determines mandatory attachments.',
      'https://hamagbicro.hr/natjecaji/'),
  const Opportunity('European Defence Fund — military AI research', 'EU · Defence / AI',
      '2026 topic closed: 29 September 2026. Monitor future calls.',
      '2026 topic budget €16 million; maximum €8 million requested per proposal.',
      'Modelling and simulation-supported AI for military decision-making and training.',
      'Collaborative defence research with specific consortium, eligibility, control and security conditions. Review the current topic rules.',
      'Expect a consortium proposal, technical work plan, partner and ownership information, budget, declarations and security documentation as applicable. Use the official call templates.',
      'https://defence-industry-space.ec.europa.eu/document/download/2cd25753-d14f-4019-8fdf-68cca55b7f17_en?filename=EDF%202026%20Call%20Topic%20Descriptions.pdf'),
  Opportunity('EIC Accelerator', 'EU · Deep tech',
      '2027: next full-proposal batch 20 January. Check short-proposal availability.',
      'Grant component below €2.5 million and investment may be available, subject to conditions.',
      'High-impact, breakthrough innovations, including AI and marine technologies where eligible.',
      'Eligible startups and SMEs; grant activities generally cover TRL 6–8. A successful short proposal precedes the full proposal.',
      'Prepare a short proposal, pitch deck, video and, if invited, a full business plan and supporting financial and technical evidence. Follow the applicable year’s templates.',
      'https://eic.ec.europa.eu/eic-funding-opportunities/eic-accelerator_en',
      calendarDate: DateTime.utc(2027, 1, 20, 16)),
  Opportunity('EIC Pre-Accelerator 2027', 'EU · Early-stage deep tech',
      'Upcoming: opens 5 May 2027; deadline 18 November 2027.',
      '€500,000–€1 million grant in 2027; up to 70% of eligible costs.',
      'Early-stage deep-tech innovations at least TRL 4; Croatian SMEs may be eligible.',
      'Single eligible company established in a widening country, including Croatia. Technology must be validated in the lab and have an adequate IP position.',
      'Submit through the EU Funding and Tenders Portal once the 2027 call opens; new templates will be published with the call.',
      'https://eic.ec.europa.eu/eic-funding-opportunities/eic-pre-accelerator_en',
      calendarDate: DateTime.utc(2027, 11, 18, 9)),
];

// Only show verified future cutoffs or published upcoming calls. Where the
// closing hour is unverified, hide the opportunity at the start of that day.
final cutoffUtc = <String, DateTime>{
  'Baltic Marine Watchdog Challenge': DateTime.utc(2026, 12, 2, 13),
  'EIC STEP Scale Up': DateTime.utc(2026, 11, 25),
  'EIC Accelerator': DateTime.utc(2027, 1, 20, 16),
  'EIC Pre-Accelerator 2027': DateTime.utc(2027, 11, 18),
};
final loans = <LoanOpportunity>[
  LoanOpportunity('HBOR loan for SME RDI and AI', 'Croatia · Innovation / AI',
    'Open while NRRP funds remain', '€100,000–€1,000,000; startups up to €500,000',
    '2% fixed per year (may be higher under state-aid rules)',
    'Croatian micro, small or medium private-sector company doing RDI or developing, implementing or using AI. Up to 75% or 85% of eligible investment; own contribution required.',
    'Equipment, software, R&D and innovation investment; check eligible cost rules and exclusions.',
    'https://www.hbor.hr/investments-by-smes-in-rdi-and-ai-under-the-national-recovery-and-resilience-plan-nrrp/2727'),
  LoanOpportunity('HAMAG-BICRO Small Loans for Industrial Transition', 'Croatia · Regional value chains',
    'Reopens 20 November 2026 at 08:00; funds are limited', 'See current programme terms',
    'See current programme terms',
    'Micro, small or medium company operating for over 3 years, headquartered and active in Panonian, Northern or Adriatic Croatia, and listed among mapped regional value-chain stakeholders.',
    'Investment aligned with an eligible regional value chain. Confirm the company and project are mapped before applying.',
    'https://hamagbicro.hr/financijski-instrumenti/kako-do-zajma/investicije/mali-zajmovi-za-industrijsku-tranziciju/'),
  LoanOpportunity('HAMAG-BICRO Micro Loans for Growth and Inclusion', 'Croatia · Start-up / inclusion',
    'Check current application availability', 'Up to €50,000',
    'Verify current rate and possible principal write-off conditions',
    'Micro and small businesses meeting the programme’s start-up or vulnerable-group criteria. Confirm ownership and age rules in the current terms.',
    'Tangible or intangible assets and limited working capital; real estate and refinancing are excluded.',
    'https://hamagbicro.hr/pitanja-i-odgovori/mikro-zajmovi-za-rast-i-ukljucenost/'),
  LoanOpportunity('HBOR loan for inventions', 'Croatia · Prototype / IP',
    'Check current programme terms', 'Loan amount subject to HBOR assessment',
    'Confirm current rate and contribution with HBOR',
    'Croatian SMEs with a certified prototype or technology and a patent/IP protection step, or qualifying development expenses after two years of operation.',
    'Equipment and other fixed assets; working capital is generally capped at 30% of investment. HBOR may finance up to 85% of estimated investment value.',
    'https://www.hbor.hr/en/kreditni_program/inventions'),
];

class LoanOpportunity {
  const LoanOpportunity(this.title, this.tag, this.status, this.amount, this.rate, this.eligibility, this.purpose, this.url);
  final String title, tag, status, amount, rate, eligibility, purpose, url;
}
List<Opportunity> opportunitiesAt(DateTime now) => allOpportunities.where((o) {
  final cutoff = cutoffUtc[o.title];
  return cutoff != null && now.toUtc().isBefore(cutoff);
}).toList();
List<Opportunity> get opportunities => opportunitiesAt(DateTime.now());

Future<void> openLink(BuildContext context, String url) async {
  try {
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) { await bridge.invokeMethod('openUrl', url); }
    else if (Platform.isWindows) { await Process.start('rundll32.exe', ['url.dll,FileProtocolHandler', url]); }
    else { throw UnsupportedError('Opening links is not supported on this platform.'); }
  } catch (_) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to open link')));
  }
}

class FundingFacts {
  const FundingFacts({required this.amount, required this.share, required this.upfront,
    required this.employees, required this.partners, required this.sales,
    required this.letters, required this.documents, required this.note, required this.checked});
  final String amount, share, upfront, employees, partners, sales, letters, documents, note, checked;
}

const unknown = 'Not verified — check call documents';
const facts = <String, FundingFacts>{
  'Baltic Marine Watchdog Challenge': FundingFacts(
    amount: 'Up to €520k / team', share: 'No required co-financing stated',
    upfront: '50% of agreed Stage 1 price at its start; up to €85k. Invoice required.',
    employees: 'No minimum FTE specified in call; confirm', partners: 'No minimum partner count specified; legal-entity applicant required',
    sales: 'No minimum sales specified in call; confirm', letters: 'No letter of intent identified; confirm submission form',
    documents: 'Online submission and Declaration of Honour required. Evidence or clearly labelled estimates; work plan, team and cost estimate.',
    note: 'Fixed-price R&D procurement: Stage 1 up to €170k, Stage 2 up to €350k. Stage 1: 50% at start, 40% after two months, 10% after final report. Costs above agreed price are your risk. Mandatory Baltic demonstration at end of Stage 1.', checked: '14 Nov 2026 · Vinnova call and participation agreement'),
  'EIC STEP Scale Up': FundingFacts(
    amount: '€10m–€30m investment (2026)', share: 'Investor capital required; not a grant',
    upfront: 'Investment timing subject to due diligence and agreement', employees: 'Startups, SMEs or small mid-caps; check size definition',
    partners: 'A single qualified investor must pre-commit', sales: 'No minimum sales verified',
    letters: 'Investor pre-commitment in official template: at least 20% of target round',
    documents: 'Business plan, pitch deck, investor pre-commitment, financial plan, freedom-to-operate analysis and key personnel CVs; check call.',
    note: '2026 target round: €50m–€150m and 3–5 times the EIC investment. Verify the rules for the applicable year.', checked: '14 Nov 2026 · EIC 2026 programme'),
  'SEAS — blue economy SMEs': FundingFacts(
    amount: 'Up to €125k / project', share: 'At least 20% of eligible costs; EU covers up to 80%',
    upfront: 'Payment schedule not verified', employees: 'Micro, small or medium-sized enterprise or startup; verify SME criteria',
    partners: 'At least 1 Croatian + 1 Italian entrepreneur; maximum 3', sales: 'Minimum sales not verified',
    letters: 'Partner letters / commitments: check guidelines', documents: 'Joint proposal, partner details and budget; confirm required forms in official guidelines.',
    note: 'Registration in an eligible Croatia–Italy programme area is required. Funding rate and other contributions can vary; verify call terms and any further cut-off.', checked: '14 Nov 2026 · SEAS call announcement'),
  'Process innovation in S3 areas': FundingFacts(
    amount: 'Check official call', share: unknown, upfront: unknown, employees: unknown, partners: unknown, sales: unknown, letters: unknown,
    documents: 'Check current application package and amendments.', note: 'Eligibility, open status and financing must be confirmed with HAMAG-BICRO.', checked: 'Listing not independently verified'),
  'Proof of innovative concept — first call': FundingFacts(
    amount: 'Check official call', share: unknown, upfront: unknown, employees: unknown, partners: unknown, sales: unknown, letters: unknown,
    documents: 'Check current application package and amendments.', note: 'Eligibility, open status and financing must be confirmed with HAMAG-BICRO.', checked: 'Listing not independently verified'),
  'European Defence Fund — military AI research': FundingFacts(
    amount: '2026 topic: up to €8m / proposal', share: unknown, upfront: unknown, employees: unknown,
    partners: 'Consortium and security rules apply; verify topic', sales: unknown, letters: unknown,
    documents: 'Check the specific call package for consortium and security documentation.', note: '2026 topic closed. Civilian yacht technology alone does not establish a defence fit.', checked: '2026 topic · verify future call'),
  'EIC Accelerator': FundingFacts(
    amount: 'Grant up to €2.5m; investment possible', share: '2027 grant: up to 70% of eligible costs; beneficiary funds 30%',
    upfront: 'Payment timing depends on agreement; verify', employees: 'SME; small mid-cap eligibility is restricted',
    partners: 'Single applicant can apply; investment terms vary', sales: 'No minimum sales verified',
    letters: 'Investor letters: verify applicable funding route', documents: 'Short proposal, pitch deck and video; full proposal if invited. Verify 2027 templates.',
    note: '2027 grant supports eligible innovation activities; the 30% applies to the grant work packages, not the separate investment component.', checked: '14 Nov 2026 · EIC 2027 work programme'),
  'EIC Pre-Accelerator 2027': FundingFacts(
    amount: '€500k–€1m grant', share: '30% of eligible costs from beneficiary resources', upfront: 'Payment schedule not verified',
    employees: 'SME criteria apply; verify size and linked companies', partners: 'Single applicant', sales: 'Minimum sales not verified',
    letters: 'Letters of intent: check 2027 call package', documents: '2027 application form will be published with the call; check the official portal.',
    note: 'Upcoming call: opens 5 May 2027. Grant covers up to 70% of eligible costs. Lab-validated technology (at least TRL 4) and appropriate IP rights required.', checked: '14 Nov 2026 · EIC Pre-Accelerator and FAQ'),
};

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
    try { await bridge.invokeMethod('syncIfEnabled', calendarItems()); } catch (_) {}
  }
  runApp(const GrantApp());
}

List<Map<String, Object>> calendarItems() => opportunities.where((o) => o.calendarDate != null)
    .map((o) => {'id': o.title, 'title': o.title, 'description': '${o.status}\nCheck the official source: ${o.url}\nThis calendar time is a reminder; verify the official closing time.', 'time': o.calendarDate!.millisecondsSinceEpoch}).toList();

String escapeCalendarText(String value) => value.replaceAll('\\', r'\\').replaceAll('\n', r'\n').replaceAll(';', r'\;').replaceAll(',', r'\,');
String foldCalendarLine(String line) {
  final result = StringBuffer();
  var bytes = 0;
  for (final rune in line.runes) {
    final character = String.fromCharCode(rune);
    final length = utf8.encode(character).length;
    if (bytes + length > 75) { result.write('\r\n '); bytes = 1; }
    result.write(character);
    bytes += length;
  }
  return '$result\r\n';
}
String utcCalendarTime(DateTime value) {
  final d = value.toUtc();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year.toString().padLeft(4, '0')}${two(d.month)}${two(d.day)}T${two(d.hour)}${two(d.minute)}${two(d.second)}Z';
}

Future<bool> openWindowsCalendar() async {
  final upcoming = opportunities.where((o) => o.calendarDate != null && o.calendarDate!.isAfter(DateTime.now())).toList();
  if (upcoming.isEmpty) return false;
  final buffer = StringBuffer('BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//Grant Compass//Funding reminders//EN\r\nCALSCALE:GREGORIAN\r\n');
  for (final o in upcoming) {
    final date = o.calendarDate!;
    buffer.write('BEGIN:VEVENT\r\n');
    buffer.write('UID:${Uri.encodeComponent(o.title)}-${date.millisecondsSinceEpoch}@grantcompass.local\r\n');
    buffer.write('DTSTAMP:${utcCalendarTime(DateTime.now())}\r\n');
    buffer.write('DTSTART:${utcCalendarTime(date)}\r\nDTEND:${utcCalendarTime(date.add(const Duration(hours: 1)))}\r\n');
    buffer.write(foldCalendarLine('SUMMARY:${escapeCalendarText(o.title)}'));
    buffer.write(foldCalendarLine('DESCRIPTION:${escapeCalendarText('${o.status}\nOfficial source: ${o.url}\nThis is a reminder time, not the official closing time.')}'));
    for (final days in [30, 21, 14]) {
      buffer.write('BEGIN:VALARM\r\nTRIGGER:-P${days}D\r\nACTION:DISPLAY\r\nDESCRIPTION:Grant deadline reminder\r\nEND:VALARM\r\n');
    }
    buffer.write('END:VEVENT\r\n');
  }
  buffer.write('END:VCALENDAR\r\n');
  final file = File('${Directory.systemTemp.path}${Platform.pathSeparator}grant-compass-reminders.ics');
  await file.writeAsString(buffer.toString(), flush: true);
  await Process.start('rundll32.exe', ['url.dll,FileProtocolHandler', file.uri.toString()]);
  return true;
}

class GrantApp extends StatelessWidget {
  const GrantApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(
    title: 'Grant Compass',
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff12647a)), useMaterial3: true),
    home: const Home());
}

class Home extends StatefulWidget { const Home({super.key}); @override State<Home> createState() => _HomeState(); }
class _HomeState extends State<Home> {
  String query = '';
  late final Timer refreshTimer;
  @override void initState() { super.initState(); refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) { if (mounted) setState(() {}); }); }
  @override void dispose() { refreshTimer.cancel(); super.dispose(); }
  Future<void> enableCalendar() async {
    if (Platform.isWindows) {
      try {
        final opened = await openWindowsCalendar();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(opened
            ? 'Calendar file created. If your calendar app opens, import or save the events.'
            : 'There are no future dated opportunities to import.')));
      } catch (_) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open a calendar app. Check your Windows .ics file association.')));
      }
      return;
    }
    if (!(Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Calendar integration is not available on this platform.')));
      return;
    }
    try {
      final result = await bridge.invokeMethod<String>('enableSync', calendarItems());
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result ?? 'Calendar request started.')));
    } on PlatformException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Calendar could not be updated.')));
    }
  }
  @override Widget build(BuildContext context) {
    final filtered = opportunities.where((o) => '${o.title} ${o.tag} ${o.fit}'.toLowerCase().contains(query.toLowerCase())).toList();
    return Scaffold(appBar: AppBar(title: const Text('Grant Compass')), body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 900), child: ListView(padding: const EdgeInsets.all(16), children: [
      Text('Funding for smarter vessels', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 8),
      const Text('EU and Croatia · Marine technology · AI · Defence · Deep tech'),
      const SizedBox(height: 12),
      const Card(child: Padding(padding: EdgeInsets.all(14), child: Text('Research snapshot checked 14 November 2026. Past cutoffs are hidden automatically; new calls and changes are not fetched. Upcoming calls are labelled. Verify the official source.'))),
      const SizedBox(height: 8),
      FilledButton.icon(onPressed: enableCalendar, icon: const Icon(Icons.calendar_month), label: Text(Platform.isWindows ? 'Import calendar reminders' : 'Connect calendar')),
      Text(Platform.isWindows ? 'Import the calendar file to add 30-day, 21-day and 14-day alerts. Previous imports are not updated automatically.' : 'The app sets alerts 30, 21 and 14 days before each listed deadline or batch. Past alert times cannot notify retroactively. Apple needs full calendar access. Older or edited events may need manual removal. The app does not fetch new calls.', style: const TextStyle(fontSize: 12)),
      const SizedBox(height: 16),
      TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), border: OutlineInputBorder(), labelText: 'Search opportunities'), onChanged: (v) => setState(() => query = v)),
      const SizedBox(height: 12),
      ...filtered.map((o) => OpportunityCard(o)),
      if (filtered.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Text('No matching opportunities in this snapshot. Check official sources for newer calls.')),
      const SizedBox(height: 20),
      Text('Loans for Croatian companies', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 8),
      const Text('Repayable financing; terms and availability can change. Check current official programme documents.'),
      const SizedBox(height: 8),
      ...loans.map((loan) => LoanCard(loan)),
      const SizedBox(height: 16),
      Text('Prepare your application', style: Theme.of(context).textTheme.titleLarge),
      const Text('Common starting materials: registration and ownership records; accounts and funding history; project and technical plan; budget and co-financing evidence; partner information; CVs and IP evidence. These are preparation suggestions, not a universal mandatory list.'),
      const SizedBox(height: 24),
    ]))));
  }
}

class LoanCard extends StatelessWidget {
  const LoanCard(this.loan, {super.key});
  final LoanOpportunity loan;
  @override Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 10), child: ExpansionTile(
    leading: const Icon(Icons.payments_outlined), title: Text(loan.title), subtitle: Text('${loan.amount} · ${loan.status}'),
    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16), children: [
      Align(alignment: Alignment.centerLeft, child: Text(loan.tag, style: Theme.of(context).textTheme.labelLarge)),
      const SizedBox(height: 8),
      _loanRow('Interest / contribution', loan.rate), _loanRow('Who may qualify', loan.eligibility), _loanRow('Potential use', loan.purpose),
      Align(alignment: Alignment.centerLeft, child: TextButton.icon(onPressed: () => openLink(context, loan.url), icon: const Icon(Icons.open_in_new), label: const Text('Official details'))),
    ]));
  Widget _loanRow(String title, String value) => Padding(padding: const EdgeInsets.only(top: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(value)]));
}

class OpportunityCard extends StatelessWidget {
  const OpportunityCard(this.o, {super.key});
  final Opportunity o;
  @override Widget build(BuildContext context) {
    final f = facts[o.title]!;
    final colors = Theme.of(context).colorScheme;
    return Card(margin: const EdgeInsets.only(bottom: 12), clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Detail(o))),
        child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(o.tag.toUpperCase(), style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 11)),
          const SizedBox(height: 6),
          Row(children: [Expanded(child: Text(o.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))), const Icon(Icons.chevron_right)]),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [FactChip(Icons.account_balance_wallet_outlined, f.amount), FactChip(Icons.pie_chart_outline, f.share)]),
          const SizedBox(height: 10), Text(o.status, style: Theme.of(context).textTheme.bodySmall),
        ]))));
  }
}

class FactChip extends StatelessWidget {
  const FactChip(this.icon, this.text, {super.key});
  final IconData icon; final String text;
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16), const SizedBox(width: 6), Flexible(child: Text(text, style: Theme.of(context).textTheme.labelMedium))]));
}

class Detail extends StatelessWidget {
  const Detail(this.o, {super.key}); final Opportunity o;
  @override Widget build(BuildContext context) {
    final f = facts[o.title]!;
    return Scaffold(appBar: AppBar(title: Text(o.title)), body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 900), child: ListView(padding: const EdgeInsets.all(20), children: [
    Text(o.tag.toUpperCase(), style: Theme.of(context).textTheme.labelLarge),
    section('Status', o.status),
    const SizedBox(height: 20),
    Text('Funding at a glance', style: Theme.of(context).textTheme.titleLarge),
    const SizedBox(height: 8),
    Card(child: Column(children: [factRow(Icons.account_balance_wallet_outlined, 'Funding', f.amount), factRow(Icons.pie_chart_outline, 'Your contribution', f.share), factRow(Icons.schedule, 'Upfront / timing', f.upfront)])),
    section('Funding rules', f.note),
    const SizedBox(height: 20), Text('Requirements', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 8),
    Card(child: Column(children: [factRow(Icons.groups_outlined, 'Employees', f.employees), factRow(Icons.handshake_outlined, 'Partners', f.partners), factRow(Icons.trending_up, 'Sales', f.sales), factRow(Icons.description_outlined, 'Letters / commitments', f.letters)])),
    section('Who can apply', o.eligibility), section('Application documents', f.documents), section('Potential fit', o.fit),
    const SizedBox(height: 18), Text('Source checked: ${f.checked}. Unverified means the rule has not been confirmed, not that no requirement exists.', style: Theme.of(context).textTheme.bodySmall),
    const SizedBox(height: 20), FilledButton.icon(onPressed: () => openLink(context, o.url), icon: const Icon(Icons.open_in_new), label: const Text('Open official source')),
  ]))));
  }
  Widget factRow(IconData icon, String label, String value) => Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 20), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 3), Text(value)]))]));
  Widget section(String title, String body) => Padding(padding: const EdgeInsets.only(top: 18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)), const SizedBox(height: 5), Text(body)]));
}
