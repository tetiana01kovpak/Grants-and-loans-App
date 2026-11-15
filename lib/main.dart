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
    'Open since 10 August 2026, while NRRP funds remain','€100,000–€1,000,000; startups up to €500,000',
    '2% fixed per year (may be higher under state-aid rules)',
    'Croatian micro, small or medium private-sector company doing RDI or developing, implementing or using AI. Up to 75% or 85% of eligible investment; own contribution required.',
    'Equipment, software, R&D and innovation investment; check eligible cost rules and exclusions.',
    'https://www.hbor.hr/investments-by-smes-in-rdi-and-ai-under-the-national-recovery-and-resilience-plan-nrrp/2727'),
  LoanOpportunity('HAMAG-BICRO Small Loans for Industrial Transition', 'Croatia · Regional value chains',
    'Applications from 20 November 2026 at 08:00, until funds run out', '€25,001–€100,000',
    '0.5%–1.5% fixed per year, depending on investment location; up to 10 years incl. up to 1 year grace; partial principal write-off possible',
    'Micro, small or medium company operating for over 3 years, headquartered and active in Panonian, Northern or Adriatic Croatia (not City of Zagreb), and listed among mapped regional value-chain stakeholders.',
    'Tangible and intangible assets aligned with an eligible regional value chain; working capital up to 30% of the loan.',
    'https://hamagbicro.hr/ponovno-otvaranje-programa-mali-zajmovi-za-industrijsku-tranziciju-prijave-od-20-studenoga-2026/'),
  LoanOpportunity('HAMAG-BICRO Micro Loan for Growth and Inclusion', 'Croatia · Start-up / inclusion',
    'Open, applications online via HAMAG-BICRO', '€1,000–€50,000',
    'Fixed: base rate minus 2.5 points, minimum 0.5% (currently 0.5%); up to 5 years incl. up to 1 year grace; up to 30% principal write-off for new hires',
    'Micro and small businesses up to 3 years old whose majority owner is aged 18–29 or 55+, has a disability, or has no completed secondary education. You can apply before registering the business.',
    'Tangible and intangible assets; working capital up to 30% of the loan. Agriculture, accommodation, transport, real estate and already-paid investments are excluded.',
    'https://hamagbicro.hr/financijski-instrumenti/kako-do-zajma/investicije/mikro-zajam-za-rast-i-unljucenost/'),
  LoanOpportunity('HBOR loan for young, women and start-up entrepreneurs', 'Croatia · Start-up / young / women',
    'Open, programme in force from July 2026', 'Up to €400,000 (from €50,000 via bank, from €100,000 direct)',
    'Via bank up to 3.00% fixed; direct HBOR 3.90% fixed (local subsidy can cut up to 2 points); up to 12 years incl. up to 3 years grace',
    'Croatian micro, small or medium business that is majority-owned by people under 41, majority women-owned and woman-led, or under 3 years old; also investments in assisted areas or RDI commercialisation.',
    'Starting or modernising a business, new technology, capacity, new products and jobs; working capital up to 30%. Bank loans up to 100% of investment, direct up to 85%.',
    'https://www.hbor.hr/poduzetnistvo-mladih-zena-pocetnika-i-ostalih-posebnih-segmenata-394/394'),
  LoanOpportunity('HBOR loan for digital transition', 'Croatia · Digital',
    'Open, programme in force from 1 July 2026', 'From €50,000 via bank or €100,000 direct; no fixed maximum',
    'Direct HBOR: 2.00% fixed up to €400,000, from 1.50% above; via bank max 3.50% fixed',
    'Croatian private-sector company of any size (not a company in difficulty).',
    'Fixed assets for strategic digital projects (100% digital coefficient under EU rules); working capital up to 30%. Up to 75%–100% of investment depending on state-aid rules.',
    'https://www.hbor.hr/ulaganja-u-digitalnu-tranziciju/2652'),
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
    required this.letters, required this.documents, required this.note, required this.checked,
    this.fundedPercent, this.ownPercent, this.fundedLabel = 'Grant covers', this.splitNote = '',
    this.documentList = const [], this.stages = const [], this.rules = const []});
  final String amount, share, upfront, employees, partners, sales, letters, documents, note, checked;
  // Share of eligible costs paid by the funder vs. by the applicant (null = not verified).
  final int? fundedPercent, ownPercent;
  final String fundedLabel, splitNote;
  final List<String> documentList, stages, rules;
}

const unknown = 'Not verified — check call documents';
const facts = <String, FundingFacts>{
  'Baltic Marine Watchdog Challenge': FundingFacts(
    amount: 'Up to €520k / team', share: 'No required co-financing stated',
    upfront: '50% of agreed Stage 1 price at its start; up to €85k. Invoice required.',
    employees: 'No minimum FTE specified in call; confirm', partners: 'No minimum partner count specified; legal-entity applicant required',
    sales: 'No minimum sales specified in call; confirm', letters: 'No letter of intent identified; confirm submission form',
    documents: 'Online submission and Declaration of Honour required. Evidence or clearly labelled estimates; work plan, team and cost estimate.',
    note: 'Fixed-price R&D procurement: Stage 1 up to €170k, Stage 2 up to €350k. Stage 1: 50% at start, 40% after two months, 10% after final report. Costs above agreed price are your risk. Mandatory Baltic demonstration at end of Stage 1.', checked: '14 Nov 2026 · Vinnova call and participation agreement',
    fundedPercent: 100, ownPercent: 0, fundedLabel: 'Contract price paid by buyer',
    splitNote: 'Pre-commercial procurement: the buyer pays the agreed fixed price. No co-financing is required, but any costs above the agreed price are your own risk.',
    documentList: ['Online submission form', 'Signed Declaration of Honour (mandatory)', 'Technical solution description with scientific data or clearly labelled estimates',
      'Work plan for Stage 1', 'Team description and key people', 'Cost estimate / fixed price offer', 'Company registration and ownership details (to prove EU/EFTA/UK headquarters and equity)'],
    stages: ['Submit by 2 December 2026, 14:00 Swedish time', 'Evaluation and selection of teams', 'Stage 1: development, up to €170k (paid 50% at start, 40% after two months, 10% after final report)',
      'Mandatory demonstration in the Baltic Sea at the end of Stage 1', 'Stage 2: further development for selected teams, up to €350k'],
    rules: ['Applicant must be a legal entity headquartered in the EU, EFTA or UK', 'Incorporated companies need at least 50% of equity held in those regions',
      'Fixed price per stage; overruns are not reimbursed', 'Must address autonomous maritime surveillance and safe navigation, not only one sub-function',
      'Other exclusions apply; read all challenge documents']),
  'EIC STEP Scale Up': FundingFacts(
    amount: '€10m–€30m investment (2026)', share: 'Investor capital required; not a grant',
    upfront: 'Investment timing subject to due diligence and agreement', employees: 'Startups, SMEs or small mid-caps; check size definition',
    partners: 'A single qualified investor must pre-commit', sales: 'No minimum sales verified',
    letters: 'Investor pre-commitment in official template: at least 20% of target round',
    documents: 'Business plan, pitch deck, investor pre-commitment, financial plan, freedom-to-operate analysis and key personnel CVs; check call.',
    note: '2026 target round: €50m–€150m and 3–5 times the EIC investment. Verify the rules for the applicable year.', checked: '15 Nov 2026 · EIC STEP Scale Up page',
    fundedLabel: 'EIC share of funding round',
    splitNote: 'Not a grant: the EIC invests equity of €10m–€30m. The total round must be 3–5 times the EIC investment, so the EIC provides roughly 20–33% and other investors the remaining 67–80%. One qualified investor must pre-commit at least 20% of the round.',
    documentList: ['Full business plan (max 50 pages) incl. ownership and financial structure', 'Pitch deck (max 15 pages, PDF)',
      'Equity pre-commitment from one qualified investor (official template)', 'Financial plan (EIC template)',
      'Freedom-to-operate results or a note of max 2 pages (a simple statement if not relevant, e.g. software)', 'CVs of key personnel'],
    stages: ['Submit on the EU Funding & Tenders Portal (open anytime; next evaluation batch 25 November 2026)', 'Evaluation; invitation to interview about 4–6 weeks after evaluation starts',
      'Interview with a jury of up to six members; results within about 2 weeks', 'Due diligence and investment agreement with the EIC Fund'],
    rules: ['Single SME or small mid-cap with fewer than 500 employees', 'Established in an EU Member State or eligible Associated Country (not the UK)',
      'Digital/deep tech, clean tech or biotech scope', 'Equity only, managed by the EIC Fund', 'An investor may apply on behalf of an eligible company']),
  'SEAS — blue economy SMEs': FundingFacts(
    amount: 'Up to €125k / project', share: 'At least 20% of eligible costs; EU covers up to 80%',
    upfront: 'Payment schedule not verified', employees: 'Micro, small or medium-sized enterprise or startup; verify SME criteria',
    partners: 'At least 1 Croatian + 1 Italian entrepreneur; maximum 3', sales: 'Minimum sales not verified',
    letters: 'Partner letters / commitments: check guidelines', documents: 'Joint proposal, partner details and budget; confirm required forms in official guidelines.',
    note: 'Registration in an eligible Croatia–Italy programme area is required. Funding rate and other contributions can vary; verify call terms and any further cut-off.', checked: '14 Nov 2026 · SEAS call announcement',
    fundedPercent: 80, ownPercent: 20),
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
    note: '2027 grant supports eligible innovation activities; the 30% applies to the grant work packages, not the separate investment component.', checked: '15 Nov 2026 · EIC Accelerator page and 2027 work programme',
    fundedPercent: 70, ownPercent: 30,
    splitNote: 'The grant (up to €2.5m) pays 70% of eligible innovation costs; you fund 30%. An optional EIC equity investment of €1m–€10m is separate and not part of this split.',
    documentList: ['Step 1 – short proposal form (about 12 pages: innovation, market, team)', 'Step 1 – pitch deck (max 10 slides, PDF)', 'Step 1 – video pitch (max 3 minutes, up to 3 core team members)',
      'Step 2 – full proposal form (up to 20 pages)', 'Step 2 – updated pitch deck and video', 'Step 2 – financial data and company structure (cap table)',
      'Step 2 – IP strategy, incl. freedom-to-operate analysis if available', 'Step 2 – implementation plan with milestones', 'Step 2 – lump-sum budget table'],
    stages: ['Step 1: short proposal – submit any time; remote evaluation, answer in about 4–6 weeks', 'Step 2: full proposal (after a GO) – submit by a batch date: 20 Jan, 17 Mar, 1 Sep or 4 Nov 2027',
      'Step 3: interview with the EIC Jury (invitation at least 2 weeks ahead; results 2–3 weeks later)', 'Step 4: grant agreement; EIC Fund due diligence if you also get investment'],
    rules: ['SME established in an EU Member State or Associated Country (or a person/company intending to set one up)', 'Grant activities at TRL 6–8; investment at TRL 6–9',
      'Grant-only support can be received only once under Horizon Europe', 'Small mid-caps (up to 499 employees) only for investment-only or exceptional blended finance',
      'Score of 13/15 or more without funding gives a Seal of Excellence']),
  'EIC Pre-Accelerator 2027': FundingFacts(
    amount: '€500k–€1m grant', share: '30% of eligible costs from beneficiary resources', upfront: 'Payment schedule not verified',
    employees: 'SME criteria apply; verify size and linked companies', partners: 'Single applicant', sales: 'Minimum sales not verified',
    letters: 'Letters of intent: check 2027 call package', documents: '2027 application form will be published with the call; check the official portal.',
    note: 'Upcoming call: opens 5 May 2027. Grant covers up to 70% of eligible costs. Lab-validated technology (at least TRL 4) and appropriate IP rights required.', checked: '15 Nov 2026 · EIC Pre-Accelerator page',
    fundedPercent: 70, ownPercent: 30,
    splitNote: 'Lump-sum grant of €500k–€1m covering 70% of eligible costs; you fund the other 30%. Project lasts up to 2 years.',
    documentList: ['2027 application form (published when the call opens on 5 May 2027)', 'Proof of TRL 4 or higher (lab validation evidence)',
      'Evidence of IP rights / freedom to operate', 'Path-to-market plan with measurable KPIs', 'Company registration in a widening country (Croatia qualifies)'],
    stages: ['Prepare using the WIDERA work programme and 2025 template', 'Call opens 5 May 2027', 'Submit on the EU Funding & Tenders Portal by 18 November 2027',
      'Evaluation and grant agreement', 'Mid-project review; access to EIC Accelerator Fast Track'],
    rules: ['Single SME or small mid-cap (one beneficiary)', 'Registered in a Horizon Europe widening country, eligible associated country or outermost region',
      'Technology at least TRL 4 (validated in the lab)', 'Must hold the IP rights needed for freedom to operate', 'Clear path to market and commitment to scale up']),
};

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
    try { await bridge.invokeMethod('syncIfEnabled', calendarItems()); } catch (_) {}
  }
  runApp(const GrantApp());
}

// Each deadline becomes one deadline event (no alert) plus separate
// "N days left" events that alert at their own start time. Separate events
// work around Google Calendar's 4-week reminder limit and Outlook's
// one-reminder-per-event limit.
const reminderDays = [30, 21, 14];
String calendarDescription(Opportunity o, String id) =>
    '${o.status}\nCheck the official source: ${o.url}\nThis calendar time is a reminder; verify the official closing time.\nGrant Compass ID: $id';
List<Map<String, Object>> calendarItems() => [
  for (final o in opportunities.where((o) => o.calendarDate != null)) ...[
    {'id': o.title, 'title': o.title, 'description': calendarDescription(o, o.title),
      'time': o.calendarDate!.millisecondsSinceEpoch, 'alert': false},
    for (final days in reminderDays)
      {'id': '${o.title} | $days days', 'title': '$days days left: ${o.title}',
        'description': calendarDescription(o, '${o.title} | $days days'),
        'time': o.calendarDate!.subtract(Duration(days: days)).millisecondsSinceEpoch, 'alert': true},
  ],
];

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
  final now = DateTime.now().millisecondsSinceEpoch;
  final upcoming = calendarItems().where((item) => (item['time'] as int) > now).toList();
  if (upcoming.isEmpty) return false;
  final buffer = StringBuffer('BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//Grant Compass//Funding reminders//EN\r\nCALSCALE:GREGORIAN\r\n');
  for (final item in upcoming) {
    final date = DateTime.fromMillisecondsSinceEpoch(item['time'] as int, isUtc: true);
    buffer.write('BEGIN:VEVENT\r\n');
    buffer.write('UID:${Uri.encodeComponent(item['id'] as String)}-${date.millisecondsSinceEpoch}@grantcompass.local\r\n');
    buffer.write('DTSTAMP:${utcCalendarTime(DateTime.now())}\r\n');
    buffer.write('DTSTART:${utcCalendarTime(date)}\r\nDTEND:${utcCalendarTime(date.add(const Duration(hours: 1)))}\r\n');
    buffer.write(foldCalendarLine('SUMMARY:${escapeCalendarText(item['title'] as String)}'));
    buffer.write(foldCalendarLine('DESCRIPTION:${escapeCalendarText(item['description'] as String)}'));
    if (item['alert'] == true) {
      buffer.write('BEGIN:VALARM\r\nTRIGGER:-PT0M\r\nACTION:DISPLAY\r\nDESCRIPTION:Grant deadline reminder\r\nEND:VALARM\r\n');
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
      Text(Platform.isWindows ? 'Import the calendar file to add "30 / 21 / 14 days left" reminder events with alerts. Previous imports are not updated automatically.' : 'The app adds "30 / 21 / 14 days left" reminder events, each with its own alert, before each listed deadline or batch. Past alert times cannot notify retroactively. Apple needs full calendar access. Older or edited events may need manual removal. The app does not fetch new calls.', style: const TextStyle(fontSize: 12)),
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

class FundingSplit extends StatelessWidget {
  const FundingSplit(this.f, {super.key});
  final FundingFacts f;
  @override Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final funded = f.fundedPercent, own = f.ownPercent;
    return Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (funded != null && own != null) ...[
        ClipRRect(borderRadius: BorderRadius.circular(6), child: SizedBox(height: 22, child: Row(children: [
          if (funded > 0) Expanded(flex: funded, child: Container(color: colors.primary)),
          if (own > 0) Expanded(flex: own, child: Container(color: colors.tertiaryContainer)),
        ]))),
        const SizedBox(height: 10),
        Row(children: [Icon(Icons.square, size: 14, color: colors.primary), const SizedBox(width: 6),
          Expanded(child: Text('${f.fundedLabel}: $funded%', style: const TextStyle(fontWeight: FontWeight.bold)))]),
        const SizedBox(height: 4),
        Row(children: [Icon(Icons.square, size: 14, color: colors.tertiaryContainer), const SizedBox(width: 6),
          Expanded(child: Text('Your own budget: $own%', style: const TextStyle(fontWeight: FontWeight.bold)))]),
        if (f.splitNote.isNotEmpty) const SizedBox(height: 10),
      ],
      if (f.splitNote.isNotEmpty) Text(f.splitNote)
      else if (funded == null) Text('Percentage split not verified. ${f.share}'),
    ])));
  }
}

class DocumentChecklist extends StatefulWidget {
  const DocumentChecklist(this.title, this.documents, {super.key});
  final String title; final List<String> documents;
  @override State<DocumentChecklist> createState() => _DocumentChecklistState();
}
class _DocumentChecklistState extends State<DocumentChecklist> {
  final done = <int>{};
  @override Widget build(BuildContext context) => Card(child: Column(children: [
    Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: Row(children: [
      Expanded(child: LinearProgressIndicator(value: done.length / widget.documents.length)),
      const SizedBox(width: 12), Text('${done.length} / ${widget.documents.length} ready'),
    ])),
    for (var i = 0; i < widget.documents.length; i++)
      CheckboxListTile(value: done.contains(i), controlAffinity: ListTileControlAffinity.leading, title: Text(widget.documents[i]),
        onChanged: (v) => setState(() => v == true ? done.add(i) : done.remove(i))),
  ]));
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
    const SizedBox(height: 20), Text('Who pays what', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 8),
    FundingSplit(f),
    if (f.stages.isNotEmpty) ...[
      const SizedBox(height: 20), Text('Stages', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 8),
      Card(child: Column(children: [for (var i = 0; i < f.stages.length; i++)
        ListTile(leading: CircleAvatar(radius: 14, child: Text('${i + 1}', style: const TextStyle(fontSize: 13))), title: Text(f.stages[i]))])),
    ],
    if (f.rules.isNotEmpty) ...[
      const SizedBox(height: 20), Text('Rules', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 8),
      Card(child: Column(children: [for (final rule in f.rules)
        ListTile(dense: true, leading: const Icon(Icons.rule, size: 20), title: Text(rule))])),
    ],
    section('Funding rules', f.note),
    const SizedBox(height: 20), Text('Requirements', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 8),
    Card(child: Column(children: [factRow(Icons.groups_outlined, 'Employees', f.employees), factRow(Icons.handshake_outlined, 'Partners', f.partners), factRow(Icons.trending_up, 'Sales', f.sales), factRow(Icons.description_outlined, 'Letters / commitments', f.letters)])),
    section('Who can apply', o.eligibility),
    if (f.documentList.isNotEmpty) ...[
      const SizedBox(height: 20), Text('Documents you need', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 4),
      Text('Tick each document as you prepare it. Always confirm the final list in the official call.', style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 8), DocumentChecklist(o.title, f.documentList),
    ] else section('Application documents', f.documents),
    section('Potential fit', o.fit),
    const SizedBox(height: 18), Text('Source checked: ${f.checked}. Unverified means the rule has not been confirmed, not that no requirement exists.', style: Theme.of(context).textTheme.bodySmall),
    const SizedBox(height: 20), FilledButton.icon(onPressed: () => openLink(context, o.url), icon: const Icon(Icons.open_in_new), label: const Text('Open official source')),
  ]))));
  }
  Widget factRow(IconData icon, String label, String value) => Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 20), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 3), Text(value)]))]));
  Widget section(String title, String body) => Padding(padding: const EdgeInsets.only(top: 18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)), const SizedBox(height: 5), Text(body)]));
}
