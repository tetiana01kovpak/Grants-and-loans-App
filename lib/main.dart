import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';

const bridge = MethodChannel('grant_compass/device');

class Opportunity {
  const Opportunity(this.title, this.tag, this.status, this.funding, this.fit,
      this.eligibility, this.documents, this.url, {this.calendarDate});
  final String title, tag, status, funding, fit, eligibility, documents, url;
  final DateTime? calendarDate;
}

final opportunities = <Opportunity>[
  Opportunity('Baltic Marine Watchdog Challenge', 'Europe · Autonomous vessels',
      'Deadline: 2 December 2026, 14:00 local Swedish time.',
      'Up to €520,000 per team in two stages; pre-commercial procurement, not a conventional grant.',
      'Autonomous maritime surveillance and safe navigation. Your navigation technology could be relevant in a team, but yacht self-parking alone does not meet the full challenge requirements.',
      'A legal entity must submit. The challenge requires complete autonomous maritime surveillance capability and Baltic demonstrations; confirm all eligibility conditions.',
      'Submit the online form and mandatory Declaration of Honour. Support claims with scientific data or clearly labelled estimates; review all challenge documents.',
      'https://www.vinnova.se/en/calls-for-proposals/radikal-innovation/the-baltic-marine-watchdog-challenge/',
      calendarDate: DateTime(2026, 12, 2, 9)),
  Opportunity('EIC STEP Scale Up', 'EU · Deep tech / AI',
      'Upcoming evaluation batch: 25 November 2026',
      '€10–30 million equity investment; this is not a grant.',
      'Scale-up of strategic digital technologies, clean technologies and biotechnology. AI and maritime projects may fit if they meet the strategic technology criteria.',
      'Eligible European startups, SMEs and small mid-caps; significant scale-up financing needs. Check the call for all conditions.',
      'The 2026 call requires a business plan (maximum 50 pages), pitch deck (maximum 15 pages), qualified investor pre-commitment using the official template, financial plan, freedom-to-operate analysis and CVs. Check the official call for details and updates.',
      'https://eic.ec.europa.eu/news/eic-selects-new-european-scale-ups-step-scale-investments-2026-07-28_en',
      calendarDate: DateTime(2026, 11, 25, 9)),
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
  const Opportunity('EIC Accelerator', 'EU · Deep tech',
      '2026 short-proposal call closed 4 November 2026; monitor the 2027 call.',
      'Grant component below €2.5 million and investment may be available, subject to conditions.',
      'High-impact, breakthrough innovations, including AI and marine technologies where eligible.',
      'Typically startups and SMEs with technology validated at least to TRL 5; full application follows a successful short proposal.',
      'Prepare a short proposal, pitch deck, video and, if invited, a full business plan and supporting financial and technical evidence. Follow the applicable year’s templates.',
      'https://ec.europa.eu/info/funding-tenders/opportunities/portal/screen/opportunities/topic-details/HORIZON-EIC-2026-ACCELERATOR-01'),
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
    try { await bridge.invokeMethod('syncIfEnabled', calendarItems()); } catch (_) {}
  }
  runApp(const GrantApp());
}

List<Map<String, Object>> calendarItems() => opportunities.where((o) => o.calendarDate != null)
    .map((o) => {'id': o.title, 'title': o.title, 'description': '${o.status}\nCheck the official source: ${o.url}\nThis calendar time is a reminder, not the official closing time.', 'time': o.calendarDate!.millisecondsSinceEpoch}).toList();

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
    buffer.write('BEGIN:VALARM\r\nTRIGGER:-P1D\r\nACTION:DISPLAY\r\nDESCRIPTION:Grant deadline reminder\r\nEND:VALARM\r\nEND:VEVENT\r\n');
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
      const Card(child: Padding(padding: EdgeInsets.all(14), child: Text('Research checked 12 November 2026. This is a starting shortlist, not a complete or live database. Funding and deadlines change; verify each official call before applying.'))),
      const SizedBox(height: 8),
      FilledButton.icon(onPressed: enableCalendar, icon: const Icon(Icons.calendar_month), label: Text(Platform.isWindows ? 'Import calendar reminders' : 'Connect calendar')),
      Text(Platform.isWindows ? 'Open a calendar file and import or save the reminders in your calendar app. This does not automatically update your calendar.' : 'With your permission, future built-in dates are added to a writable calendar with a one-day reminder. The app checks its built-in dates when opened; it does not fetch new calls.', style: const TextStyle(fontSize: 12)),
      const SizedBox(height: 16),
      TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), border: OutlineInputBorder(), labelText: 'Search opportunities'), onChanged: (v) => setState(() => query = v)),
      const SizedBox(height: 12),
      ...filtered.map((o) => Card(child: ListTile(title: Text(o.title), subtitle: Text('${o.tag}\n${o.status}'), isThreeLine: true, trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Detail(o))))),
      if (filtered.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Text('No matching opportunities.')),
      const SizedBox(height: 16),
      Text('Prepare your application', style: Theme.of(context).textTheme.titleLarge),
      const Text('Common starting materials: registration and ownership records; accounts and funding history; project and technical plan; budget and co-financing evidence; partner information; CVs and IP evidence. These are preparation suggestions, not a universal mandatory list.'),
      const SizedBox(height: 24),
    ]))));
  }
}

class Detail extends StatelessWidget {
  const Detail(this.o, {super.key}); final Opportunity o;
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(o.title)), body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 900), child: ListView(padding: const EdgeInsets.all(20), children: [
    Text(o.tag, style: Theme.of(context).textTheme.labelLarge),
    section('Status', o.status), section('Funding', o.funding), section('Potential fit', o.fit),
    section('Who can apply', o.eligibility), section('Documents to prepare', o.documents),
    const SizedBox(height: 20), FilledButton.icon(onPressed: () async {
      try {
        if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) { await bridge.invokeMethod('openUrl', o.url); }
        else if (Platform.isWindows) { await Process.start('rundll32.exe', ['url.dll,FileProtocolHandler', o.url]); }
        else { throw UnsupportedError('Opening links is not supported on this platform.'); }
      } catch (_) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to open link')));
      }
    }, icon: const Icon(Icons.open_in_new), label: const Text('Open official source')),
  ]))));
  Widget section(String title, String body) => Padding(padding: const EdgeInsets.only(top: 18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)), const SizedBox(height: 5), Text(body)]));
}
