import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merkado/providers/cart_provider.dart';
import 'package:merkado/providers/customer_ordered_products_provider.dart';
import 'package:merkado/providers/organization_products_provider.dart';
import 'package:merkado/screens/customer_screens/customer_drawer_screens/customer_my_orders.dart';
import 'package:merkado/screens/customer_screens/customer_history.dart';
import 'package:merkado/screens/customer_screens/selected_product_marketplace.dart';
import 'package:merkado/screens/farmer_screens/farmer_all_location_screen.dart';
import 'package:merkado/screens/farmer_screens/farmer_my_purchases.dart';
import 'package:merkado/screens/organization_screens/organization_all_location_screen.dart';
import 'package:merkado/screens/organization_screens/organization_market_screen.dart';
import 'package:merkado/screens/customer_screens/tab_controllers.dart';
import 'package:merkado/screens/farmer_screens/farmer_my_edit_products.dart';
import 'package:merkado/screens/organization_screens/organization_my_edit_products.dart';
import 'package:merkado/screens/organization_screens/organization_customer_orders.dart';
import 'package:merkado/screens/organization_screens/organization_my_purchases.dart';

import 'package:merkado/screens/organization_screens/organization_screen_controller.dart';
import 'package:merkado/screens/organization_screens/organization_settings_screen.dart';

import 'providers/farmer_products_provider.dart';

import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'providers/auth_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/farmers_provider.dart';
import 'providers/organization_provider.dart';

import 'screens/authentication/user/forgot_password.dart';
import 'screens/authentication/user/login_screen.dart';
import 'screens/authentication/user/register_screen.dart';

import 'screens/customer_screens/user_org_chat_screen.dart';
import 'screens/farmer_screens/farmer_org_chat_screen.dart';
import 'screens/farmer_screens/farmer_settings_screen.dart';
import 'screens/farmer_screens/receiver_farmer_farmer_chat_screen.dart';
import 'screens/organization_screens/org_org_chat_screen.dart';
import 'screens/organization_screens/organization_chat_screen.dart';
import 'screens/organization_screens/organization_farmer_chat_screen.dart';
import 'screens/organization_screens/organization_location_screen.dart';

import 'screens/farmer_screens/farmer_location_screen.dart';
import 'screens/farmer_screens/farmer_drawer_screens/farmer_customer_order.dart';
import 'screens/farmer_screens/farmer_drawer_screens/farmer_my_products.dart';
import 'screens/farmer_screens/farmer_screen_controller.dart';
import 'screens/farmer_screens/farmer_new_post.dart';
import 'screens/farmer_screens/farmer_chat_screen.dart';
import 'screens/farmer_screens/farmer_farmer_chat_screen.dart';

import 'screens/customer_screens/customer_history.dart';
import 'screens/customer_screens/splash_screen.dart';
import 'screens/customer_screens/user_chat_screen.dart';
import 'screens/customer_screens/user_location_screen.dart';
import 'screens/customer_screens/cart_screen.dart';
import 'screens/customer_screens/user_settings_screen.dart';
import 'screens/customer_screens/marketplace_screen.dart';
import 'screens/customer_screens/user_screen_controller.dart';
import 'screens/organization_screens/receiver_org_org_chat_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyA_JVEXL6cLkdg8SHHeSv46MwfXygNluPY',
      appId: '1:386692353743:android:016a59a6abd4bdf204f1ba',
      messagingSenderId: '386692353743',
      projectId: 'merkado-cfaa7',
      storageBucket: 'merkado-cfaa7.appspot.com',
    ),
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (_) => runApp(
      const Merkado(),
    ),
  );
}

class Merkado extends StatefulWidget {
  const Merkado({Key? key}) : super(key: key);

  @override
  State<Merkado> createState() => _MerkadoState();
}

class _MerkadoState extends State<Merkado> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => FarmersProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => OrganizationProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => CustomersProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => FarmerProducts(),
        ),
        ChangeNotifierProvider(
          create: (context) => OrganizationProducts(),
        ),
        ChangeNotifierProvider(
          create: (context) => CustomerOrderedProducts(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Merkado',
        theme: ThemeData(
          primarySwatch: const MaterialColor(0xFF000000, {
            50: Color(0xFF000000),
            100: Color(0xFF000000),
            200: Color(0xFF000000),
            300: Color(0xFF000000),
            400: Color(0xFF000000),
            500: Color(0xFF000000),
            600: Color(0xFF000000),
            700: Color(0xFF000000),
            800: Color(0xFF000000),
            900: Color(0xFF000000),
          }),
        ),
        home: const SplashScreen(),
        routes: {
          //User Side Routes
          SplashScreen.routeName: (ctx) => const SplashScreen(),
          TabControllers.routeName: (ctx) => const TabControllers(),
          CustomerHistory.routeName: (ctx) => const CustomerHistory(),
          RegisterScreen.routeName: (ctx) => const RegisterScreen(),
          LoginScreen.routeName: (ctx) => const LoginScreen(),
          ForgotPasswordScreen.routeName: (ctx) => const ForgotPasswordScreen(),
          UserLocationScreen.routeName: (ctx) => const UserLocationScreen(),
          MarketplaceScreen.routeName: (ctx) => const MarketplaceScreen(),
          SelectedProductMarketplace.routeName: (ctx) =>
              const SelectedProductMarketplace(),
          CustomerMyOrders.routeName: (ctx) => const CustomerMyOrders(),

          UserScreenController.routeName: (ctx) => const UserScreenController(),
          CartScreen.routeName: (ctx) => const CartScreen(),
          UserSettingsScreen.routeName: (ctx) => const UserSettingsScreen(),
          UserChatScreen.routeName: (ctx) {
            final args =
                ModalRoute.of(ctx)!.settings.arguments as UserChatArguments;
            return UserChatScreen(
              userId: FirebaseAuth.instance.currentUser!.uid,
              userType: UserType.customers,
              displayName: args.displayName,
              farmerId: args.farmerId,
            );
          },
          OrgChatScreen.routeName: (ctx) {
            final args =
                ModalRoute.of(ctx)!.settings.arguments as OrgChatArguments;
            return OrgChatScreen(
              userId: FirebaseAuth.instance.currentUser!.uid,
              orgType: OrgType.customers,
              displayName: args.displayName,
              orgId: args.orgId,
            );
          },

          //Farmer Side Routes
          FarmerScreenController.routeName: (ctx) =>
              const FarmerScreenController(),
          FarmerLocationScreen.routeName: (ctx) => const FarmerLocationScreen(),
          FarmerCustomerOrders.routeName: (ctx) => const FarmerCustomerOrders(),
          FarmerMyProducts.routeName: (ctx) => const FarmerMyProducts(),
          FarmerNewProductPost.routeName: (ctx) => const FarmerNewProductPost(),
          FarmerSettingsScreen.routeName: (ctx) => const FarmerSettingsScreen(),
          FarmerMyEditProducts.routeName: (ctx) => const FarmerMyEditProducts(),
          FarmerMyPurchases.routeName: (ctx) => const FarmerMyPurchases(),
          FarmerAllLocationScreen.routeName: (ctx) =>
              const FarmerAllLocationScreen(),
          FarmerChatScreen.routeName: (ctx) {
            final args =
                ModalRoute.of(ctx)!.settings.arguments as FarmerChatArguments;
            return FarmerChatScreen(
              userId: FirebaseAuth.instance.currentUser!.uid,
              userType: FarmerType.customers,
              displayName: args.displayName,
              customerId: args.customerId,
            );
          },
          FarmerToFarmerChatScreen.routeName: (ctx) {
            final args =
                ModalRoute.of(ctx)!.settings.arguments as FarmersChatArguments;
            return FarmerToFarmerChatScreen(
              userId: FirebaseAuth.instance.currentUser!.uid,
              userType: FarmersType.farmer,
              displayName: args.displayName,
              customerId: args.farmerId,
            );
          },
          ReceiverFarmerToFarmerChatScreen.routeName: (ctx) {
            final args =
                ModalRoute.of(ctx)!.settings.arguments as FarmersChatArguments;
            return ReceiverFarmerToFarmerChatScreen(
              userId: FirebaseAuth.instance.currentUser!.uid,
              userType: ReceiverFarmersType.customers,
              displayName: args.displayName,
              customerId: args.farmerId,
            );
          },
          FarmerToOrgChatScreen.routeName: (ctx) {
            final args = ModalRoute.of(ctx)!.settings.arguments
                as FarmerToOrgChatArguments;
            return FarmerToOrgChatScreen(
              userId: FirebaseAuth.instance.currentUser!.uid,
              userType: FarmerToOrgType.farmer,
              displayName: args.displayName,
              orgId: args.orgId,
            );
          },

          //Organization Side Routes

          OrganizationLocationScreen.routeName: (ctx) =>
              const OrganizationLocationScreen(),
          OrgScreenController.routeName: (ctx) => const OrgScreenController(),
          OrgMarketScreen.routeName: (ctx) => const OrgMarketScreen(),
          OrgSettingsScreen.routeName: (ctx) => const OrgSettingsScreen(),
          OrgMyEditProducts.routeName: (ctx) => const OrgMyEditProducts(),
          OrgAllLocationScreen.routeName: (ctx) => const OrgAllLocationScreen(),
          OrgCustomerOrders.routeName: (ctx) => const OrgCustomerOrders(),
          OrganizationMyPurchases.routeName: (ctx) =>
              const OrganizationMyPurchases(),

          OrganizationChatScreen.routeName: (ctx) {
            final args = ModalRoute.of(ctx)!.settings.arguments
                as OrganizationChatArguments;
            return OrganizationChatScreen(
              userId: FirebaseAuth.instance.currentUser!.uid,
              userType: OrganizationType.customers,
              displayName: args.displayName,
              customerId: args.customerId,
            );
          },
          OrgToFarmerChatScreen.routeName: (ctx) {
            final args = ModalRoute.of(ctx)!.settings.arguments
                as OrgToFarmerChatArguments;
            return OrgToFarmerChatScreen(
              userId: FirebaseAuth.instance.currentUser!.uid,
              userType: OrgToFarmerType.organization,
              displayName: args.displayName,
              farmerId: args.farmerId,
            );
          },
          OrgToOrgChatScreen.routeName: (ctx) {
            final args =
                ModalRoute.of(ctx)!.settings.arguments as OrgToOrgChatArguments;
            return OrgToOrgChatScreen(
              userId: FirebaseAuth.instance.currentUser!.uid,
              userType: OrgToOrgType.organization,
              displayName: args.displayName,
              customerId: args.orgId,
            );
          },
          ReceiverOrgToOrgChatScreen.routeName: (ctx) {
            final args = ModalRoute.of(ctx)!.settings.arguments
                as ReceiverOrgToOrgChatArguments;
            return ReceiverOrgToOrgChatScreen(
              userId: FirebaseAuth.instance.currentUser!.uid,
              userType: ReceiverOrgToOrgType.customers,
              displayName: args.displayName,
              customerId: args.orgId,
            );
          },
        },
      ),
    );
  }
}
