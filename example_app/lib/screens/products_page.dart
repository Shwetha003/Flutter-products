import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';
import 'cart_page.dart';
import '../models/auth_model.dart';
import '../services/product_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductService.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    //final cart = Provider.of<CartProvider>(context);
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          // cart
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CartPage()),
                ),
              ),
              if (cart.totalItems > 0)
                Positioned(
                  right: 8.w,
                  top: 8.h,
                  child: CircleAvatar(
                    radius: 10.r,
                    backgroundColor: Colors.red,
                    child: Text(
                      cart.totalItems.toString(),
                      style: TextStyle(fontSize: 12.sp, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),

          // profile
          Builder(
            builder: (buttonContext) => IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () async {
                // 🔥 NEW: compute button position for dropdown
                final renderBox = buttonContext.findRenderObject() as RenderBox;
                final offset = renderBox.localToGlobal(Offset.zero);
                final dropdownWidth = 500.w;
                await showMenu(
                  context: buttonContext,
                  position: RelativeRect.fromLTRB(
                    offset.dx,
                    offset.dy + renderBox.size.height,
                    offset.dx + dropdownWidth,
                    0,
                  ),
                  items: [
                    PopupMenuItem(
                      //  fixed width dropdown
                      child: SizedBox(
                        width: dropdownWidth,
                        child: _ProfileDropdown(),
                      ),
                    ),
                    //New support menu item
                    PopupMenuItem(
                      child: ListTile(
                        leading: const Icon(Icons.support_agent),
                        title: const Text('Support'),
                        onTap: () => context.push('/support'),
                        // onTap: () {
                        //   //close the menu first
                        //   Navigator.of(context).pop();
                        //   //then navigate
                        //   context.push('/support');
                        // },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),

      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \${snapshot.error}'));
          } else {
            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      cart.addItem(product);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

//profile dropdown widget

class _ProfileDropdown extends StatefulWidget {
  @override
  State<_ProfileDropdown> createState() => _ProfileDropdownState();
}

class _ProfileDropdownState extends State<_ProfileDropdown> {
  final _nameCtrl = TextEditingController();
  String? _email;
  double? _latitude;
  double? _longitude;
  bool _locating = false;

  //secure storage instance for name
  final _secureStorage = const FlutterSecureStorage();
  static const _nameKey = 'user_name';
  static const _imageKey = 'profile_image_path';

  String? _imagePath; // to hold the loaded image path
  final ImagePicker _picker = ImagePicker(); //picker instance

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _fetchLocation();
  }

  //write name to secure storage
  Future<void> _saveName() async {
    await _secureStorage.write(key: _nameKey, value: _nameCtrl.text.trim());
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Name saved securely')));
  }

  //load name&email&image from secure storage
  Future<void> _loadProfile() async {
    final storedName = await _secureStorage.read(key: _nameKey) ?? '';
    _nameCtrl.text = storedName;
    _imagePath = await _secureStorage.read(key: _imageKey);
    _email = Provider.of<AuthModel>(context, listen: false).currentUserEmail;
    setState(() {});
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      await _secureStorage.write(key: _imageKey, value: picked.path);
      setState(() => _imagePath = picked.path);
    }
  }

  Future<void> _fetchLocation() async {
    // 🔥 NEW
    setState(() => _locating = true);
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // You could show an error/snackbar here
      setState(() => _locating = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _locating = false);
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() => _locating = false);
      return;
    }

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    setState(() {
      _latitude = pos.latitude;
      _longitude = pos.longitude;
      _locating = false;
    });
  }

  Future<void> _logout() async {
    await Provider.of<AuthModel>(context, listen: false).logout();
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // profile picture display
        Center(
          child: GestureDetector(
            onTap: _pickImage, // open camera
            child: CircleAvatar(
              radius: 100.r,
              backgroundImage: _imagePath != null
                  ? FileImage(File(_imagePath!))
                  : null,
              child: _imagePath == null
                  ? Icon(Icons.camera_alt, size: 30.r)
                  : null,
            ),
          ),
        ),
        SizedBox(height: 12.h),

        // 🔥 NEW: Location display section
        Text('Location:', style: TextStyle(fontSize: 35.sp)),
        if (_locating)
          Row(
            children: [
              SizedBox(
                width: 16.w,
                height: 16.h,
                child: CircularProgressIndicator(strokeWidth: 2.w),
              ),
              SizedBox(width: 8.w),
              Text('Fetching…'),
            ],
          )
        else if (_latitude != null && _longitude != null)
          Text(
            'Lat: ${_latitude!.toStringAsFixed(4)}, '
            'Lng: ${_longitude!.toStringAsFixed(4)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          )
        else
          TextButton.icon(
            icon: const Icon(Icons.location_on),
            label: const Text('Get Location'),
            onPressed: _fetchLocation,
          ),

        Divider(height: 30.h),

        Text('Email:', style: TextStyle(fontSize: 35.sp)),
        Text(_email ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8.h),
        TextField(
          controller: _nameCtrl,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              vertical: 15.h,
              horizontal: 15.w,
            ),
            border: OutlineInputBorder(),
            hintText: 'Your Name',
          ),
        ),

        SizedBox(height: 4.h),
        ElevatedButton(onPressed: _saveName, child: const Text('Save')),
        const Divider(),
        Center(
          child: TextButton(
            onPressed: _logout,
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ),
      ],
    );
  }
}
