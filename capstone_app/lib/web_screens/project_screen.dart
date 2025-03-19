import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../models/data_service.dart';
import '../web_common/project_tab_widget.dart';
import '../web_common/project_form_widget.dart';
import '../web_common/cargo_details_table_widget.dart';
import '../web_common/work_scope_widget.dart';
import '../web_common/offsite_checklist_widget.dart';
import 'msra_generation_screen.dart';
import 'onsite_checklist_screen.dart';

class ProjectScreen extends StatefulWidget {
  final String? projectId;
  const ProjectScreen({super.key, this.projectId});

  @override
  _ProjectScreenState createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  Project? _project;
  bool isNewProject = true;
  bool isOOG = false;
  bool isLoading = true;
  bool hasRun = false; // Track whether "Run" button was pressed
  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProjectData();
  }

  void _loadProjectData() async {
    if (widget.projectId != null) {
      List<Project> projects = await DataService.getProjects();
      Project? foundProject = projects.firstWhere(
        (p) => p.projectId == widget.projectId,
        orElse: () => Project(
          client: '',
          projectId: '',
          projectName: '',
          projectType: '',
          startDestination: '',
          endDestination: '',
          currentTask: '',
          projectStatus: '',
          startDate: DateTime.now(),
          cargo: [],
          scope: [],
        ),
      );

      if (foundProject.projectId.isNotEmpty) {
        setState(() {
          _project = foundProject;
          isNewProject = false;
          isOOG = foundProject.projectType == "OOG";
          hasRun = isOOG; // If existing project is OOG, assume run has been executed
          isLoading = false;
        });
      }
    } else {
      setState(() {
        _project = Project(
          client: '',
          projectId: '',
          projectName: '',
          projectType: '',
          startDestination: '',
          endDestination: '',
          currentTask: '',
          projectStatus: '',
          startDate: DateTime.now(),
          cargo: [],
          scope: [],
        );
        isNewProject = true;
        isLoading = false;
      });
    }
  }

  void _onRunPressed() {
    setState(() {
      isOOG = true; 
      hasRun = true; 
      _project = Project(
        client: _project!.client,
        projectId: _project!.projectId,
        projectName: _project!.projectName,
        projectType: "OOG", // ✅ Now properly updates projectType
        startDestination: _project!.startDestination,
        endDestination: _project!.endDestination,
        currentTask: _project!.currentTask,
        projectStatus: _project!.projectStatus,
        startDate: _project!.startDate,
        cargo: _project!.cargo,
        scope: _project!.scope,
      );
    });
  }

void onTabSelected(int index) {
  setState(() {
    selectedTabIndex = index;
  });

    switch (index) {
      case 1: // ✅ Navigate to MS/RA Generation
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MSRAGenerationScreen(),
          ),
        );
        break;
        
      case 2: // ✅ Navigate to Onsite Checklist
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OnsiteChecklistScreen(),
          ),
        );
        break;

      default:
        break;
    }
}


  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isNewProject ? "New Project" : _project!.projectName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isNewProject && isOOG)
            ProjectTabWidget(
              selectedTabIndex: selectedTabIndex, 
              onTabSelected: onTabSelected
            ),
          
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // **Project Form Widget**
                          ProjectFormWidget(project: _project, isNewProject: isNewProject),
                          const SizedBox(height: 20),

                          // **Cargo Table Widget**
                          CargoDetailsTableWidget(
                            cargoList: _project!.cargo,
                            isNewProject: isNewProject,
                            isEditable: isNewProject,
                            hasRun: hasRun,
                            onRunPressed: _onRunPressed,
                            projectType: _project!.projectType, // Pass projectType to update Result column
                          ),

                          const SizedBox(height: 20),

                          // **Work Scope (Only if Project is OOG)**
                          if (isOOG)
                            ConstrainedBox( 
                              constraints: const BoxConstraints(maxHeight: 500), // ✅ Adjust max height if needed
                              child: WorkScopeWidget(
                                isNewProject: isNewProject,
                                ),
                            ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),

                if (isOOG)
                  Container(
                    width: 250, // ✅ Fixed width
                    padding: const EdgeInsets.all(16.0),
                    child: OffsiteChecklistWidget(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}









