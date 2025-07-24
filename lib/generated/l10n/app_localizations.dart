import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ca'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
  ];

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'MiProveedor'**
  String get appName;

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get loading;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In es, this message translates to:
  /// **'Añadir'**
  String get add;

  /// No description provided for @search.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get search;

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In es, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In es, this message translates to:
  /// **'Sí'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @error.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In es, this message translates to:
  /// **'Éxito'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In es, this message translates to:
  /// **'Advertencia'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In es, this message translates to:
  /// **'Información'**
  String get info;

  /// No description provided for @back.
  ///
  /// In es, this message translates to:
  /// **'Atrás'**
  String get back;

  /// No description provided for @next.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get next;

  /// No description provided for @finish.
  ///
  /// In es, this message translates to:
  /// **'Finalizar'**
  String get finish;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @refresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get refresh;

  /// No description provided for @login.
  ///
  /// In es, this message translates to:
  /// **'Iniciar Sesión'**
  String get login;

  /// No description provided for @register.
  ///
  /// In es, this message translates to:
  /// **'Registrarse'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar Sesión'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In es, this message translates to:
  /// **'Correo Electrónico'**
  String get email;

  /// No description provided for @password.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In es, this message translates to:
  /// **'Confirmar Contraseña'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta?'**
  String get alreadyHaveAccount;

  /// No description provided for @loginAsEmployee.
  ///
  /// In es, this message translates to:
  /// **'Empleado'**
  String get loginAsEmployee;

  /// No description provided for @loginAsAdmin.
  ///
  /// In es, this message translates to:
  /// **'Administrador'**
  String get loginAsAdmin;

  /// No description provided for @registerNewCompany.
  ///
  /// In es, this message translates to:
  /// **'Registrar Nueva Empresa'**
  String get registerNewCompany;

  /// No description provided for @joinExistingCompany.
  ///
  /// In es, this message translates to:
  /// **'Unirse a Empresa'**
  String get joinExistingCompany;

  /// No description provided for @companyCode.
  ///
  /// In es, this message translates to:
  /// **'Código de Empresa'**
  String get companyCode;

  /// No description provided for @enterCompanyCode.
  ///
  /// In es, this message translates to:
  /// **'Introduce el código de empresa'**
  String get enterCompanyCode;

  /// No description provided for @fullName.
  ///
  /// In es, this message translates to:
  /// **'Nombre Completo'**
  String get fullName;

  /// No description provided for @companyName.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la Empresa'**
  String get companyName;

  /// No description provided for @companyAddress.
  ///
  /// In es, this message translates to:
  /// **'Dirección de la Empresa'**
  String get companyAddress;

  /// No description provided for @companyPhone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono de la Empresa'**
  String get companyPhone;

  /// No description provided for @welcome.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido'**
  String get welcome;

  /// No description provided for @welcomeBack.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido de nuevo'**
  String get welcomeBack;

  /// No description provided for @dashboard.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get dashboard;

  /// No description provided for @quickActions.
  ///
  /// In es, this message translates to:
  /// **'Acciones Rápidas'**
  String get quickActions;

  /// No description provided for @recentOrders.
  ///
  /// In es, this message translates to:
  /// **'Pedidos Recientes'**
  String get recentOrders;

  /// No description provided for @pendingApprovals.
  ///
  /// In es, this message translates to:
  /// **'Pendientes de Aprobación'**
  String get pendingApprovals;

  /// No description provided for @totalSpent.
  ///
  /// In es, this message translates to:
  /// **'Gasto Total'**
  String get totalSpent;

  /// No description provided for @thisMonth.
  ///
  /// In es, this message translates to:
  /// **'Este mes'**
  String get thisMonth;

  /// No description provided for @activeEmployees.
  ///
  /// In es, this message translates to:
  /// **'Empleados Activos'**
  String get activeEmployees;

  /// No description provided for @todaysOrders.
  ///
  /// In es, this message translates to:
  /// **'Pedidos de Hoy'**
  String get todaysOrders;

  /// No description provided for @suppliers.
  ///
  /// In es, this message translates to:
  /// **'Proveedores'**
  String get suppliers;

  /// No description provided for @supplier.
  ///
  /// In es, this message translates to:
  /// **'Proveedor'**
  String get supplier;

  /// No description provided for @addSupplier.
  ///
  /// In es, this message translates to:
  /// **'Añadir Proveedor'**
  String get addSupplier;

  /// No description provided for @editSupplier.
  ///
  /// In es, this message translates to:
  /// **'Editar Proveedor'**
  String get editSupplier;

  /// No description provided for @supplierName.
  ///
  /// In es, this message translates to:
  /// **'Nombre del Proveedor'**
  String get supplierName;

  /// No description provided for @supplierEmail.
  ///
  /// In es, this message translates to:
  /// **'Email del Proveedor'**
  String get supplierEmail;

  /// No description provided for @supplierPhone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono del Proveedor'**
  String get supplierPhone;

  /// No description provided for @supplierAddress.
  ///
  /// In es, this message translates to:
  /// **'Dirección del Proveedor'**
  String get supplierAddress;

  /// No description provided for @supplierImage.
  ///
  /// In es, this message translates to:
  /// **'Imagen del Proveedor'**
  String get supplierImage;

  /// No description provided for @selectImage.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Imagen'**
  String get selectImage;

  /// No description provided for @noSuppliersFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron proveedores'**
  String get noSuppliersFound;

  /// No description provided for @createFirstSupplier.
  ///
  /// In es, this message translates to:
  /// **'Crea tu primer proveedor'**
  String get createFirstSupplier;

  /// No description provided for @products.
  ///
  /// In es, this message translates to:
  /// **'Productos'**
  String get products;

  /// No description provided for @product.
  ///
  /// In es, this message translates to:
  /// **'Producto'**
  String get product;

  /// No description provided for @addProduct.
  ///
  /// In es, this message translates to:
  /// **'Añadir Producto'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In es, this message translates to:
  /// **'Editar Producto'**
  String get editProduct;

  /// No description provided for @productName.
  ///
  /// In es, this message translates to:
  /// **'Nombre del Producto'**
  String get productName;

  /// No description provided for @productCategory.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get productCategory;

  /// No description provided for @productPrice.
  ///
  /// In es, this message translates to:
  /// **'Precio'**
  String get productPrice;

  /// No description provided for @productUnit.
  ///
  /// In es, this message translates to:
  /// **'Unidad'**
  String get productUnit;

  /// No description provided for @productImage.
  ///
  /// In es, this message translates to:
  /// **'Imagen del Producto'**
  String get productImage;

  /// No description provided for @importFromExcel.
  ///
  /// In es, this message translates to:
  /// **'Importar desde Excel'**
  String get importFromExcel;

  /// No description provided for @exportToExcel.
  ///
  /// In es, this message translates to:
  /// **'Exportar a Excel'**
  String get exportToExcel;

  /// No description provided for @noProductsFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron productos'**
  String get noProductsFound;

  /// No description provided for @selectSupplierFirst.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un proveedor primero'**
  String get selectSupplierFirst;

  /// No description provided for @categories.
  ///
  /// In es, this message translates to:
  /// **'Categorías'**
  String get categories;

  /// No description provided for @allCategories.
  ///
  /// In es, this message translates to:
  /// **'Todas las Categorías'**
  String get allCategories;

  /// No description provided for @orders.
  ///
  /// In es, this message translates to:
  /// **'Pedidos'**
  String get orders;

  /// No description provided for @order.
  ///
  /// In es, this message translates to:
  /// **'Pedido'**
  String get order;

  /// No description provided for @newOrder.
  ///
  /// In es, this message translates to:
  /// **'Nuevo Pedido'**
  String get newOrder;

  /// No description provided for @createOrder.
  ///
  /// In es, this message translates to:
  /// **'Crear Pedido'**
  String get createOrder;

  /// No description provided for @editOrder.
  ///
  /// In es, this message translates to:
  /// **'Editar Pedido'**
  String get editOrder;

  /// No description provided for @orderDetails.
  ///
  /// In es, this message translates to:
  /// **'Detalles del Pedido'**
  String get orderDetails;

  /// No description provided for @orderNumber.
  ///
  /// In es, this message translates to:
  /// **'Número de Pedido'**
  String get orderNumber;

  /// No description provided for @orderDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha del Pedido'**
  String get orderDate;

  /// No description provided for @orderStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado del Pedido'**
  String get orderStatus;

  /// No description provided for @orderTotal.
  ///
  /// In es, this message translates to:
  /// **'Total del Pedido'**
  String get orderTotal;

  /// No description provided for @selectSupplier.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Proveedor'**
  String get selectSupplier;

  /// No description provided for @addProducts.
  ///
  /// In es, this message translates to:
  /// **'Añadir Productos'**
  String get addProducts;

  /// No description provided for @quantity.
  ///
  /// In es, this message translates to:
  /// **'Cantidad'**
  String get quantity;

  /// No description provided for @unit.
  ///
  /// In es, this message translates to:
  /// **'unidad'**
  String get unit;

  /// No description provided for @price.
  ///
  /// In es, this message translates to:
  /// **'Precio'**
  String get price;

  /// No description provided for @total.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @subtotal.
  ///
  /// In es, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @taxes.
  ///
  /// In es, this message translates to:
  /// **'Impuestos'**
  String get taxes;

  /// No description provided for @cart.
  ///
  /// In es, this message translates to:
  /// **'Carrito'**
  String get cart;

  /// No description provided for @addToCart.
  ///
  /// In es, this message translates to:
  /// **'Añadir al Carrito'**
  String get addToCart;

  /// No description provided for @removeFromCart.
  ///
  /// In es, this message translates to:
  /// **'Quitar del Carrito'**
  String get removeFromCart;

  /// No description provided for @clearCart.
  ///
  /// In es, this message translates to:
  /// **'Vaciar Carrito'**
  String get clearCart;

  /// No description provided for @emptyCart.
  ///
  /// In es, this message translates to:
  /// **'Carrito vacío'**
  String get emptyCart;

  /// No description provided for @proceedToCheckout.
  ///
  /// In es, this message translates to:
  /// **'Proceder al Pago'**
  String get proceedToCheckout;

  /// No description provided for @sendOrder.
  ///
  /// In es, this message translates to:
  /// **'Enviar Pedido'**
  String get sendOrder;

  /// No description provided for @approveOrder.
  ///
  /// In es, this message translates to:
  /// **'Aprobar Pedido'**
  String get approveOrder;

  /// No description provided for @rejectOrder.
  ///
  /// In es, this message translates to:
  /// **'Rechazar Pedido'**
  String get rejectOrder;

  /// No description provided for @generatePDF.
  ///
  /// In es, this message translates to:
  /// **'Generar PDF'**
  String get generatePDF;

  /// No description provided for @sendWhatsApp.
  ///
  /// In es, this message translates to:
  /// **'Enviar por WhatsApp'**
  String get sendWhatsApp;

  /// No description provided for @sendEmail.
  ///
  /// In es, this message translates to:
  /// **'Enviar por Email'**
  String get sendEmail;

  /// No description provided for @pending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get pending;

  /// No description provided for @approved.
  ///
  /// In es, this message translates to:
  /// **'Aprobado'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In es, this message translates to:
  /// **'Rechazado'**
  String get rejected;

  /// No description provided for @sent.
  ///
  /// In es, this message translates to:
  /// **'Enviado'**
  String get sent;

  /// No description provided for @delivered.
  ///
  /// In es, this message translates to:
  /// **'Entregado'**
  String get delivered;

  /// No description provided for @cancelled.
  ///
  /// In es, this message translates to:
  /// **'Cancelado'**
  String get cancelled;

  /// No description provided for @draft.
  ///
  /// In es, this message translates to:
  /// **'Borrador'**
  String get draft;

  /// No description provided for @employees.
  ///
  /// In es, this message translates to:
  /// **'Empleados'**
  String get employees;

  /// No description provided for @employee.
  ///
  /// In es, this message translates to:
  /// **'Empleado'**
  String get employee;

  /// No description provided for @admin.
  ///
  /// In es, this message translates to:
  /// **'Administrador'**
  String get admin;

  /// No description provided for @role.
  ///
  /// In es, this message translates to:
  /// **'Rol'**
  String get role;

  /// No description provided for @employeeManagement.
  ///
  /// In es, this message translates to:
  /// **'Gestión de Empleados'**
  String get employeeManagement;

  /// No description provided for @employeeLimits.
  ///
  /// In es, this message translates to:
  /// **'Límites de Empleados'**
  String get employeeLimits;

  /// No description provided for @maxOrderAmount.
  ///
  /// In es, this message translates to:
  /// **'Límite por Pedido'**
  String get maxOrderAmount;

  /// No description provided for @monthlyLimit.
  ///
  /// In es, this message translates to:
  /// **'Límite Mensual'**
  String get monthlyLimit;

  /// No description provided for @setLimits.
  ///
  /// In es, this message translates to:
  /// **'Establecer Límites'**
  String get setLimits;

  /// No description provided for @settings.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settings;

  /// No description provided for @generalSettings.
  ///
  /// In es, this message translates to:
  /// **'Configuración General'**
  String get generalSettings;

  /// No description provided for @companySettings.
  ///
  /// In es, this message translates to:
  /// **'Configuración de Empresa'**
  String get companySettings;

  /// No description provided for @notificationSettings.
  ///
  /// In es, this message translates to:
  /// **'Configuración de Notificaciones'**
  String get notificationSettings;

  /// No description provided for @appearance.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get theme;

  /// No description provided for @textSize.
  ///
  /// In es, this message translates to:
  /// **'Tamaño de Texto'**
  String get textSize;

  /// No description provided for @lightTheme.
  ///
  /// In es, this message translates to:
  /// **'Tema Claro'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In es, this message translates to:
  /// **'Tema Oscuro'**
  String get darkTheme;

  /// No description provided for @systemTheme.
  ///
  /// In es, this message translates to:
  /// **'Automático'**
  String get systemTheme;

  /// No description provided for @smallText.
  ///
  /// In es, this message translates to:
  /// **'Pequeño'**
  String get smallText;

  /// No description provided for @normalText.
  ///
  /// In es, this message translates to:
  /// **'Normal'**
  String get normalText;

  /// No description provided for @largeText.
  ///
  /// In es, this message translates to:
  /// **'Grande'**
  String get largeText;

  /// No description provided for @notifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notifications;

  /// No description provided for @pushNotifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones Push'**
  String get pushNotifications;

  /// No description provided for @emailNotifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones por Email'**
  String get emailNotifications;

  /// No description provided for @orderNotifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones de Pedidos'**
  String get orderNotifications;

  /// No description provided for @employeeNotifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones de Empleados'**
  String get employeeNotifications;

  /// No description provided for @security.
  ///
  /// In es, this message translates to:
  /// **'Seguridad'**
  String get security;

  /// No description provided for @changePassword.
  ///
  /// In es, this message translates to:
  /// **'Cambiar Contraseña'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña Actual'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In es, this message translates to:
  /// **'Nueva Contraseña'**
  String get newPassword;

  /// No description provided for @biometricAuth.
  ///
  /// In es, this message translates to:
  /// **'Autenticación Biométrica'**
  String get biometricAuth;

  /// No description provided for @enableBiometric.
  ///
  /// In es, this message translates to:
  /// **'Habilitar Biométrica'**
  String get enableBiometric;

  /// No description provided for @disableBiometric.
  ///
  /// In es, this message translates to:
  /// **'Deshabilitar Biométrica'**
  String get disableBiometric;

  /// No description provided for @help.
  ///
  /// In es, this message translates to:
  /// **'Ayuda'**
  String get help;

  /// No description provided for @support.
  ///
  /// In es, this message translates to:
  /// **'Soporte'**
  String get support;

  /// No description provided for @helpCenter.
  ///
  /// In es, this message translates to:
  /// **'Centro de Ayuda'**
  String get helpCenter;

  /// No description provided for @contactSupport.
  ///
  /// In es, this message translates to:
  /// **'Contactar Soporte'**
  String get contactSupport;

  /// No description provided for @sendFeedback.
  ///
  /// In es, this message translates to:
  /// **'Enviar Comentarios'**
  String get sendFeedback;

  /// No description provided for @aboutApp.
  ///
  /// In es, this message translates to:
  /// **'Acerca de la App'**
  String get aboutApp;

  /// No description provided for @version.
  ///
  /// In es, this message translates to:
  /// **'Versión'**
  String get version;

  /// No description provided for @termsAndConditions.
  ///
  /// In es, this message translates to:
  /// **'Términos y Condiciones'**
  String get termsAndConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In es, this message translates to:
  /// **'Política de Privacidad'**
  String get privacyPolicy;

  /// No description provided for @rateApp.
  ///
  /// In es, this message translates to:
  /// **'Calificar App'**
  String get rateApp;

  /// No description provided for @loginSuccessful.
  ///
  /// In es, this message translates to:
  /// **'Inicio de sesión exitoso'**
  String get loginSuccessful;

  /// No description provided for @loginFailed.
  ///
  /// In es, this message translates to:
  /// **'Error al iniciar sesión'**
  String get loginFailed;

  /// No description provided for @registerSuccessful.
  ///
  /// In es, this message translates to:
  /// **'Registro exitoso'**
  String get registerSuccessful;

  /// No description provided for @registerFailed.
  ///
  /// In es, this message translates to:
  /// **'Error al registrarse'**
  String get registerFailed;

  /// No description provided for @passwordChanged.
  ///
  /// In es, this message translates to:
  /// **'Contraseña cambiada exitosamente'**
  String get passwordChanged;

  /// No description provided for @passwordChangeFailed.
  ///
  /// In es, this message translates to:
  /// **'Error al cambiar contraseña'**
  String get passwordChangeFailed;

  /// No description provided for @orderCreated.
  ///
  /// In es, this message translates to:
  /// **'Pedido creado exitosamente'**
  String get orderCreated;

  /// No description provided for @orderUpdated.
  ///
  /// In es, this message translates to:
  /// **'Pedido actualizado exitosamente'**
  String get orderUpdated;

  /// No description provided for @orderDeleted.
  ///
  /// In es, this message translates to:
  /// **'Pedido eliminado exitosamente'**
  String get orderDeleted;

  /// No description provided for @supplierCreated.
  ///
  /// In es, this message translates to:
  /// **'Proveedor creado exitosamente'**
  String get supplierCreated;

  /// No description provided for @supplierUpdated.
  ///
  /// In es, this message translates to:
  /// **'Proveedor actualizado exitosamente'**
  String get supplierUpdated;

  /// No description provided for @supplierDeleted.
  ///
  /// In es, this message translates to:
  /// **'Proveedor eliminado exitosamente'**
  String get supplierDeleted;

  /// No description provided for @productCreated.
  ///
  /// In es, this message translates to:
  /// **'Producto creado exitosamente'**
  String get productCreated;

  /// No description provided for @productUpdated.
  ///
  /// In es, this message translates to:
  /// **'Producto actualizado exitosamente'**
  String get productUpdated;

  /// No description provided for @productDeleted.
  ///
  /// In es, this message translates to:
  /// **'Producto eliminado exitosamente'**
  String get productDeleted;

  /// No description provided for @dataImported.
  ///
  /// In es, this message translates to:
  /// **'Datos importados exitosamente'**
  String get dataImported;

  /// No description provided for @dataExported.
  ///
  /// In es, this message translates to:
  /// **'Datos exportados exitosamente'**
  String get dataExported;

  /// No description provided for @emailSent.
  ///
  /// In es, this message translates to:
  /// **'Email enviado exitosamente'**
  String get emailSent;

  /// No description provided for @whatsappSent.
  ///
  /// In es, this message translates to:
  /// **'Mensaje de WhatsApp enviado'**
  String get whatsappSent;

  /// No description provided for @pdfGenerated.
  ///
  /// In es, this message translates to:
  /// **'PDF generado exitosamente'**
  String get pdfGenerated;

  /// No description provided for @settingsSaved.
  ///
  /// In es, this message translates to:
  /// **'Configuración guardada'**
  String get settingsSaved;

  /// No description provided for @languageChanged.
  ///
  /// In es, this message translates to:
  /// **'Idioma cambiado exitosamente'**
  String get languageChanged;

  /// No description provided for @themeChanged.
  ///
  /// In es, this message translates to:
  /// **'Tema cambiado exitosamente'**
  String get themeChanged;

  /// No description provided for @biometricEnabled.
  ///
  /// In es, this message translates to:
  /// **'Autenticación biométrica habilitada'**
  String get biometricEnabled;

  /// No description provided for @biometricDisabled.
  ///
  /// In es, this message translates to:
  /// **'Autenticación biométrica deshabilitada'**
  String get biometricDisabled;

  /// No description provided for @noInternetConnection.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión a internet'**
  String get noInternetConnection;

  /// No description provided for @connectionRestored.
  ///
  /// In es, this message translates to:
  /// **'Conexión restaurada'**
  String get connectionRestored;

  /// No description provided for @sessionExpired.
  ///
  /// In es, this message translates to:
  /// **'Sesión expirada'**
  String get sessionExpired;

  /// No description provided for @invalidCredentials.
  ///
  /// In es, this message translates to:
  /// **'Credenciales inválidas'**
  String get invalidCredentials;

  /// No description provided for @userNotFound.
  ///
  /// In es, this message translates to:
  /// **'Usuario no encontrado'**
  String get userNotFound;

  /// No description provided for @emailAlreadyExists.
  ///
  /// In es, this message translates to:
  /// **'El email ya está registrado'**
  String get emailAlreadyExists;

  /// No description provided for @weakPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña muy débil'**
  String get weakPassword;

  /// No description provided for @passwordMismatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get passwordMismatch;

  /// No description provided for @invalidEmail.
  ///
  /// In es, this message translates to:
  /// **'Email inválido'**
  String get invalidEmail;

  /// No description provided for @requiredField.
  ///
  /// In es, this message translates to:
  /// **'Campo requerido'**
  String get requiredField;

  /// No description provided for @invalidCompanyCode.
  ///
  /// In es, this message translates to:
  /// **'Código de empresa inválido'**
  String get invalidCompanyCode;

  /// No description provided for @companyNotFound.
  ///
  /// In es, this message translates to:
  /// **'Empresa no encontrada'**
  String get companyNotFound;

  /// No description provided for @permissionDenied.
  ///
  /// In es, this message translates to:
  /// **'Permiso denegado'**
  String get permissionDenied;

  /// No description provided for @fileNotFound.
  ///
  /// In es, this message translates to:
  /// **'Archivo no encontrado'**
  String get fileNotFound;

  /// No description provided for @uploadFailed.
  ///
  /// In es, this message translates to:
  /// **'Error al subir archivo'**
  String get uploadFailed;

  /// No description provided for @downloadFailed.
  ///
  /// In es, this message translates to:
  /// **'Error al descargar archivo'**
  String get downloadFailed;

  /// No description provided for @operationCancelled.
  ///
  /// In es, this message translates to:
  /// **'Operación cancelada'**
  String get operationCancelled;

  /// No description provided for @unexpectedError.
  ///
  /// In es, this message translates to:
  /// **'Error inesperado'**
  String get unexpectedError;

  /// No description provided for @kg.
  ///
  /// In es, this message translates to:
  /// **'kg'**
  String get kg;

  /// No description provided for @g.
  ///
  /// In es, this message translates to:
  /// **'g'**
  String get g;

  /// No description provided for @l.
  ///
  /// In es, this message translates to:
  /// **'l'**
  String get l;

  /// No description provided for @ml.
  ///
  /// In es, this message translates to:
  /// **'ml'**
  String get ml;

  /// No description provided for @box.
  ///
  /// In es, this message translates to:
  /// **'caja'**
  String get box;

  /// No description provided for @package.
  ///
  /// In es, this message translates to:
  /// **'paquete'**
  String get package;

  /// No description provided for @bottle.
  ///
  /// In es, this message translates to:
  /// **'botella'**
  String get bottle;

  /// No description provided for @can.
  ///
  /// In es, this message translates to:
  /// **'lata'**
  String get can;

  /// No description provided for @piece.
  ///
  /// In es, this message translates to:
  /// **'pieza'**
  String get piece;

  /// No description provided for @euro.
  ///
  /// In es, this message translates to:
  /// **'€'**
  String get euro;

  /// No description provided for @dollar.
  ///
  /// In es, this message translates to:
  /// **'\$'**
  String get dollar;

  /// No description provided for @pound.
  ///
  /// In es, this message translates to:
  /// **'£'**
  String get pound;

  /// No description provided for @today.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In es, this message translates to:
  /// **'Ayer'**
  String get yesterday;

  /// No description provided for @tomorrow.
  ///
  /// In es, this message translates to:
  /// **'Mañana'**
  String get tomorrow;

  /// No description provided for @thisWeek.
  ///
  /// In es, this message translates to:
  /// **'Esta semana'**
  String get thisWeek;

  /// No description provided for @lastWeek.
  ///
  /// In es, this message translates to:
  /// **'Semana pasada'**
  String get lastWeek;

  /// No description provided for @nextWeek.
  ///
  /// In es, this message translates to:
  /// **'Próxima semana'**
  String get nextWeek;

  /// No description provided for @lastMonth.
  ///
  /// In es, this message translates to:
  /// **'Mes pasado'**
  String get lastMonth;

  /// No description provided for @nextMonth.
  ///
  /// In es, this message translates to:
  /// **'Próximo mes'**
  String get nextMonth;

  /// No description provided for @thisYear.
  ///
  /// In es, this message translates to:
  /// **'Este año'**
  String get thisYear;

  /// No description provided for @lastYear.
  ///
  /// In es, this message translates to:
  /// **'Año pasado'**
  String get lastYear;

  /// No description provided for @nextYear.
  ///
  /// In es, this message translates to:
  /// **'Próximo año'**
  String get nextYear;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In es, this message translates to:
  /// **'Por favor introduce tu email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In es, this message translates to:
  /// **'Por favor introduce tu contraseña'**
  String get pleaseEnterPassword;

  /// No description provided for @pleaseEnterName.
  ///
  /// In es, this message translates to:
  /// **'Por favor introduce tu nombre'**
  String get pleaseEnterName;

  /// No description provided for @pleaseSelectSupplier.
  ///
  /// In es, this message translates to:
  /// **'Por favor selecciona un proveedor'**
  String get pleaseSelectSupplier;

  /// No description provided for @pleaseAddProducts.
  ///
  /// In es, this message translates to:
  /// **'Por favor añade productos al pedido'**
  String get pleaseAddProducts;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In es, this message translates to:
  /// **'Por favor introduce un email válido'**
  String get pleaseEnterValidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 6 caracteres'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get passwordsDoNotMatch;

  /// No description provided for @fieldRequired.
  ///
  /// In es, this message translates to:
  /// **'Este campo es requerido'**
  String get fieldRequired;

  /// No description provided for @invalidNumber.
  ///
  /// In es, this message translates to:
  /// **'Número inválido'**
  String get invalidNumber;

  /// No description provided for @mustBePositive.
  ///
  /// In es, this message translates to:
  /// **'Debe ser un número positivo'**
  String get mustBePositive;

  /// No description provided for @maxLengthExceeded.
  ///
  /// In es, this message translates to:
  /// **'Máximo de caracteres excedido'**
  String get maxLengthExceeded;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ca', 'en', 'es', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppLocalizationsCa();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
