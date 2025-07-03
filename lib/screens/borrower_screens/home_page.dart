import 'package:flutter/material.dart';
import 'package:theloanapp/widgets/TextStyles.dart';
import 'package:theloanapp/widgets/appbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BorrowerHomePage extends ConsumerStatefulWidget {
  BorrowerHomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<BorrowerHomePage> {
  int _selectedIndex = 0;

  final List<Map<String, String>> loancategories = [
    {"title": "Apparel", "icon": "assets/apparel.jpg"},
    {"title": "Beauty", "icon": "assets/beauty.jpg"},
    {"title": "Electronics", "icon": "assets/electronics.jpg"},
    {"title": "Home", "icon": "assets/home.jpg"},
  ];

  final List<Map<String, String>> trendingStores = [
    {
      "title": "Insting Store",
      "subtitle": "Big saving on furniture",
      "image": "assets/first.jpg",
    },
    {
      "title": "Electronics",
      "subtitle": "Low installments",
      "image": "assets/second.jpg",
    },
    {
      "title": "Furniture",
      "subtitle": "Big discount on furniture",
      "image": "assets/third.webp",
    },
    {
      "title": "Insting Car",
      "subtitle": "Big discount on Cars",
      "image": "assets/fourth.webp",
    },
  ];


  // --- Search related state ---
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Map<String, String>> _searchResults = [];
  bool _showSearchResults = false;

  final List<String> transactionPurposes = [
    "Deposit",
    "Loan Repayment",
    "Transfer",
    "Investment in loans pool",
    "Wallet Initialization"
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _search(String query) {
    query = query.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
      return;
    }

    final List<Map<String, String>> results = [];

    // Search in loan 
    for (final cat in loancategories) {
      if (cat["title"]!.toLowerCase().contains(query)) {
        results.add({
          "type": "categories",
          "title": cat["title"]!,
        });
      }
    }

    // Search in trending stores
    for (final store in trendingStores) {
      if (store["title"]!.toLowerCase().contains(query) ||
          (store["subtitle"]?.toLowerCase().contains(query) ?? false)) {
        results.add({
          "type": "store",
          "title": store["title"]!,
        });
      }
    }

    // Search in transaction purposes
    for (final purpose in transactionPurposes) {
      if (purpose.toLowerCase().contains(query)) {
        results.add({
          "type": "transaction",
          "title": purpose,
        });
      }
    }

    // Search for direct page navigation
    if ("loans".contains(query)) {
      results.add({"type": "page", "title": "Loans"});
    }
    if ("wallet".contains(query)) {
      results.add({"type": "page", "title": "Wallet"});
    }
    if ("history".contains(query)) {
      results.add({"type": "page", "title": "History"});
    }
    if ("chat".contains(query)) {
      results.add({"type": "page", "title": "Chat"});
    }
    if ("home".contains(query)) {
      results.add({"type": "page", "title": "Home"});
    }

    setState(() {
      _searchResults = results;
      _showSearchResults = results.isNotEmpty;
    });
  }

  void _handleSearchTap(Map<String, String> result) {
    setState(() {
      _showSearchResults = false;
      _searchController.clear();
      FocusScope.of(context).unfocus();
    });

    // Navigation logic
    switch (result["type"]) {
      case "category":
        context.push("/loan_request", extra: result["title"]);
        break;
      case "store":
        context.push("/loan_request", extra: result["title"]);
        break;
      case "transaction":
        context.push("/transaction_history");
        break;
      case "page":
        final page = result["title"]!.toLowerCase();
        if (page == "loans") {
          context.push("/loans_taken");
        } else if (page == "wallet") {
          context.push("/wallet");
        } else if (page == "history") {
          context.push("/transaction_history");
        } else if (page == "chat") {
          context.push("/chat");
        } else if (page == "home") {
          context.push("/borrowerNavigation");
        }
        break;
      default:
        break;
    }
  }

  void _onSearchSubmitted(String value) {
    if (_searchResults.isNotEmpty) {
      _handleSearchTap(_searchResults.first);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: showAppBar(context, ref),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final gridItemWidth = (constraints.maxWidth - 16 * 2 - 12) / 2;
          final gridImageHeight = gridItemWidth * 0.9;
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                myPoppinText("Manage loan", FontWeight.bold, 20),
                SizedBox(height: 25),
                // --- Search Field ---
                TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: "Search loan,  shop or pay ...",
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: _search,
                  onSubmitted: _onSearchSubmitted,
                  onTap: () {
                    if (_searchResults.isNotEmpty) {
                      setState(() {
                        _showSearchResults = true;
                      });
                    }
                  },
                ),
                // --- Live Search Results List ---
                if (_showSearchResults && _searchResults.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: 4, bottom: 12),
                    constraints: BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, idx) {
                        final result = _searchResults[idx];
                        return ListTile(
                          title: Text(result["title"]!),
                          subtitle: Text(result["type"]!),
                          onTap: () => _handleSearchTap(result),
                        );
                      },
                    ),
                  ),
                SizedBox(height: 25),
                // Loan categories
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [myPoppinText("Loan Categories", FontWeight.w500, 18)],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: loancategories.map((category) {
                    return Flexible(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: constraints.maxWidth * 0.08,
                            backgroundColor: Colors.grey[200],
                            child: Image.asset(category["icon"]!, width: constraints.maxWidth * 0.07),
                          ),
                          SizedBox(height: 6),
                          myPoppinText(category["title"]!, FontWeight.normal, 12),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 25),
                // Trending Store
                myPoppinText("Trending Store", FontWeight.w500, 18),
                SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.all(0),
                  itemCount: trendingStores.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final store = trendingStores[index];
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[100],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              context.push("/loan_request", extra: store["title"]);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                store["image"]!,
                                width: double.infinity,
                                height: gridImageHeight,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                myPoppinText(store["title"]!, FontWeight.w400, 14),
                                SizedBox(height: 4),
                                myPoppinText(
                                  store["subtitle"]!,
                                  FontWeight.normal,
                                  11,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}