import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/file_system/file_system.dart';

// ignore: implementation_imports
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer_plugin/plugin/assist_mixin.dart';
import 'package:analyzer_plugin/plugin/completion_mixin.dart';
import 'package:analyzer_plugin/plugin/folding_mixin.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart' as plugin;
import 'package:analyzer_plugin/protocol/protocol_generated.dart' as plugin;
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/assist/assist_contributor_mixin.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_dart.dart';
import 'package:analyzer_plugin/utilities/completion/completion_core.dart';
import 'package:analyzer_plugin/utilities/folding/folding.dart';

/// Analyzer plugin for built_value.
///
/// Surfaces the same errors as the generator at compile time, with fixes
/// where possible.
class TestPlugin extends ServerPlugin
    with
        CompletionMixin,
        DartCompletionMixin,
        AssistsMixin,
        DartAssistsMixin,
        FoldingMixin,
        DartFoldingMixin {
  TestPlugin(ResourceProvider provider) : super(provider);

  @override
  List<String> get fileGlobsToAnalyze => <String>['**/*.dart'];

  @override
  String get name => 'My fantastic plugin';

  @override
  String get version => '1.0.0';

  @override
  AnalysisDriverGeneric createAnalysisDriver(plugin.ContextRoot contextRoot) {
    // TODO: implement createAnalysisDriver
    return null;
  }

  @override
  void sendNotificationsForSubscriptions(
      Map<String, List<plugin.AnalysisService>> subscriptions) {
    // TODO: implement sendNotificationsForSubscriptions
  }

  @override
  List<CompletionContributor> getCompletionContributors(String path) {
    // TODO: implement getCompletionContributors
    return [MyCompletionContributor()];
  }

  @override
  List<AssistContributor> getAssistContributors(String path) {
    return <AssistContributor>[new MyAssistContributor()];
  }

  @override
  List<FoldingContributor> getFoldingContributors(String path) {
    return <FoldingContributor>[new MyFoldingContributor()];
  }
}

class MyCompletionContributor implements CompletionContributor {
  @override
  Future<void> computeSuggestions(
      DartCompletionRequest request, CompletionCollector collector) async {
    var sug = plugin.CompletionSuggestion(
      plugin.CompletionSuggestionKind.KEYWORD,
      10000,
      "hiha",
      0,
      0,
      false,
      false,
    );
    collector.addSuggestion(sug);
  }
}

class MyAssistContributor extends Object
    with AssistContributorMixin
    implements AssistContributor {
  static AssistKind wrapInIf =
      new AssistKind('wrapInIf', 100, "Wrap in an 'if' statement");

  DartAssistRequest request;

  AssistCollector collector;

  AnalysisSession get session => request.result.session;

  @override
  void computeAssists(DartAssistRequest request, AssistCollector collector) {
    this.request = request;
    this.collector = collector;
    _wrapInIf();
    _wrapInWhile();
    // ...
  }

  void _wrapInIf() {
    ChangeBuilder builder = new DartChangeBuilder(session);
    addAssist(wrapInIf, builder);
  }

  void _wrapInWhile() {
    // ...
  }
}

class MyFoldingContributor implements FoldingContributor {
  @override
  void computeFolding(FoldingRequest request, FoldingCollector collector) {
    if (request is DartFoldingRequest) {
      FoldingVisitor visitor = new FoldingVisitor(collector);
      request.result.unit.accept(visitor);
    }
  }
}

class FoldingVisitor extends RecursiveAstVisitor {
  final FoldingCollector collector;

  FoldingVisitor(this.collector);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    collector.addRegion(80, 100, plugin.FoldingKind.FILE_HEADER);
    collector.addRegion(0, 10, plugin.FoldingKind.FILE_HEADER);
    collector.addRegion(0, 15, plugin.FoldingKind.FILE_HEADER);
    collector.addRegion(5, 30, plugin.FoldingKind.FILE_HEADER);
  }
}
