import 'package:serviexpress_app/features/onboarding/domain/entities/onboarding_page.dart';

abstract class OnboardingLocalDatasource {
  Future<List<OnboardingPage>> getOnboardingPages();
}

class OnboardingLocalDatasourceImpl implements OnboardingLocalDatasource {
  @override
  Future<List<OnboardingPage>> getOnboardingPages() async {
    return const [
      OnboardingPage(
        imagePath: "assets/icons/onborning_one.svg",
        title: "¡Tu hogar en buenas manos!",
        description:
            "Solicita servicios de limpieza, pintura y más, desde tu celular y sin complicaciones.",
      ),
      OnboardingPage(
        imagePath: "assets/icons/onborning_two.svg",
        title: "Profesionales verificados",
        description:
            "Elige a expertos calificados, revisa opiniones y programa el servicio según tu horario.",
      ),
      OnboardingPage(
        imagePath: "assets/icons/onborning_three.svg",
        title: "Paga con garantía",
        description:
            "Tu dinero está protegido hasta que el servicio esté completado. Sin sorpresas, sin riesgos.",
      ),
    ];
  }
}
