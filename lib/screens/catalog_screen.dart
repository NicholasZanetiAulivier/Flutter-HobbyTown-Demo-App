import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hobby_town_demo/components/catalog_item.dart';
import 'package:hobby_town_demo/models/item.dart';
import 'package:hobby_town_demo/providers/catalog_provider.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController textController = TextEditingController();
  bool focus = false;

  List<String> searchHistory = [
    "History 1",
    "History 2",
    "History 3",
    "History 4",
  ];

  List<Item> items = [];

  @override
  void activate() {
    super.activate();
    scrollController.jumpTo(0);
    textController.text = "";
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      items = ref.watch(itemsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Column(
        children: [
          SizedBox(height: 64),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.search, size: 20),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 18,
                        child: Focus(
                          onFocusChange: (focus) {
                            setState(() {
                              this.focus = focus;
                            });
                          },
                          child: TextField(
                            style: Theme.of(context).textTheme.displaySmall,
                            controller: textController,
                            expands: false,
                            maxLength: 30,
                            buildCounter: (
                              context, {
                              required currentLength,
                              required isFocused,
                              required maxLength,
                            }) => null,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            stylusHandwritingEnabled: false,
                            decoration: InputDecoration(
                              hintText: "Cari produk",
                              border: InputBorder.none,
                              fillColor: Colors.white,
                              floatingLabelAlignment:
                                  FloatingLabelAlignment.center,
                            ),
                            textAlignVertical: TextAlignVertical.center,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        textController.clear();
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      icon: Icon(Icons.cancel, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),
          focus
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Pencarian Terakhir",
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          GestureDetector(
                            onTap: () {
                              //TODO: IMPLEMENT
                              setState(() {
                                searchHistory.clear();
                              });
                            },
                            child: Text(
                              "Hapus Semua",
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : SizedBox.shrink(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    focus
                        ? ListView.builder(
                            itemBuilder: (context, index) => _SearchHistoryItem(
                              context,
                              searchHistory[index],
                              index,
                            ),
                            itemCount: searchHistory.length,
                            shrinkWrap: true,
                            padding: EdgeInsets.only(top: 12, bottom: 24),
                          )
                        : SizedBox.shrink(),
                    Align(
                      alignment: AlignmentGeometry.centerLeft,
                      child: Text(
                        "Mungkin Kamu Suka",
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                    GridView.count(
                      padding: EdgeInsets.only(top: 24),
                      physics: ScrollPhysics(),
                      crossAxisCount: 2,
                      children: items.map((i) => CatalogItem(item: i)).toList(),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      childAspectRatio: 145 / 250,
                    ),
                    SizedBox(height: 50),
                    Text(
                      "-- batas --",
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _SearchHistoryItem(BuildContext context, String name, int index) {
    return Row(
      spacing: 8,
      children: [
        Icon(Icons.history, size: 18),
        Expanded(
          child: Text(name, style: Theme.of(context).textTheme.titleMedium),
        ),
        IconButton(
          icon: Icon(Icons.cancel_sharp),
          onPressed: () {
            setState(() {
              searchHistory.removeAt(index);
            });
          },
        ),
      ],
    );
  }
}
