import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imageLib;
import 'package:path_provider/path_provider.dart';
import 'package:photofilters/filters/filters.dart';

class PhotoFilter extends StatelessWidget {
  final imageLib.Image image;
  final String filename;
  final Filter filter;
  final BoxFit fit;
  final Widget loader;

  PhotoFilter({
    @required this.image,
    @required this.filename,
    @required this.filter,
    this.fit = BoxFit.fill,
    this.loader = const Center(child: CircularProgressIndicator()),
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<int>>(
      future: compute(applyFilter, <String, dynamic>{
        "filter": filter,
        "image": image,
        "filename": filename,
      }),
      builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return loader;
          case ConnectionState.active:
          case ConnectionState.waiting:
            return loader;
          case ConnectionState.done:
            if (snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));
            return Image.memory(
              snapshot.data,
              fit: fit,
            );
        }
        return null; // unreachable
      },
    );
  }
}

///The PhotoFilterSelector Widget for apply filter from a selected set of filters
class PhotoFilterSelector extends StatefulWidget {
  final Widget title;
  final Color appBarColor;
  final List<Filter> filters;
  final imageLib.Image image;
  final Widget loader;
  final BoxFit fit;
  final String filename;
  final bool circleShape;

  const PhotoFilterSelector({
    Key key,
    @required this.title,
    @required this.filters,
    @required this.image,
    this.appBarColor = Colors.blue,
    this.loader = const Center(child: CircularProgressIndicator()),
    this.fit = BoxFit.fill,
    @required this.filename,
    this.circleShape = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _PhotoFilterSelectorState();
}

class _PhotoFilterSelectorState extends State<PhotoFilterSelector> {
  String filename;
  Map<String, List<int>> cachedFilters = {};
  Filter _filter;
  imageLib.Image image;
  bool loading;

  @override
  void initState() {
    super.initState();
    loading = false;
    _filter = widget.filters[0];
    filename = widget.filename;
    image = widget.image;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white12,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: AppBar(
            title: widget.title,
            elevation: 0,
            backgroundColor: Colors.pink[900],
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 36,
              ),
              onPressed: () {
                Navigator.pop(context);
                print("Get.back()");
              },
            ),
            actions: <Widget>[
              loading
                  ? Container()
                  : IconButton(
                      icon: Icon(
                        Icons.arrow_forward,
                        color: Colors.blue,
                        size: 36,
                      ),
                      onPressed: () async {
                        setState(() {
                          loading = true;
                        });
                        var imageFile = await saveFilteredImage();

                        Navigator.pop(context, {'image_filtered': imageFile});
                      },
                    )
            ],
          ),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: loading
              ? widget.loader
              : Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        padding: EdgeInsets.all(12.0),
                        child: _buildFilteredImage(
                          _filter,
                          image,
                          filename,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                          // color: Colors.amber,
                           margin: EdgeInsets.fromLTRB(4,10,4,40),
                           
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.filters.length,
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              child: Container(
                               
                                 margin: EdgeInsets.all(4),
                          
                                padding: EdgeInsets.all(2.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    _buildFilterThumbnail(
                                        widget.filters[index], image, filename),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Text(
                                      widget.filters[index].name,
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ],
                                ),
                              ),
                              onTap: () => setState(() {
                                _filter = widget.filters[index];
                              }),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  _buildFilterThumbnail(Filter filter, imageLib.Image image, String filename) {
    if (cachedFilters[filter?.name ?? "_"] == null) {
      return FutureBuilder<List<int>>(
        future: compute(applyFilter, <String, dynamic>{
          "filter": filter,
          "image": image,
          "filename": filename,
        }),
        builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return 
              
              // CircleAvatar(
              //   radius: 50.0,
              //   child: Center(
              //     child: widget.loader,
              //   ),
              //   backgroundColor: Colors.black12,
              // );

              Center(
                child: Container(
                  
                  
                  height: 90.0,
                  width: 90.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                  ),
                ),
              );

            case ConnectionState.done:
              if (snapshot.hasError)
                return Center(child: Text('Error: ${snapshot.error}'));
              cachedFilters[filter?.name ?? "_"] = snapshot.data;
              return Container(
               
                height: 90.0,
                width: 90.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: MemoryImage(
                      snapshot.data,
                    ),
                    fit: BoxFit.cover,
                  ),
                  shape: BoxShape.rectangle,
                ),
              );

            // CircleAvatar(
            //   radius: 50.0,
            //   backgroundImage: MemoryImage(
            //     snapshot.data,
            //   ),
            //   backgroundColor: Colors.black38,
            // );
          }
          return null; // unreachable
        },
      );
    } else {
      return
          // CircleAvatar(
          //   radius: 50.0,
          //   backgroundImage: MemoryImage(
          //     cachedFilters[filter?.name ?? "_"],
          //   ),
          //   backgroundColor: Colors.white,
          // );
          Container(
            //color: Colors.amber,
        height: 90.0,
        width: 90.0,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: MemoryImage(cachedFilters[filter?.name ?? "_"]),
            fit: BoxFit.cover,
          ),
          shape: BoxShape.rectangle,
        ),
      );
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/filtered_${_filter?.name ?? "_"}_$filename');
  }

  Future<File> saveFilteredImage() async {
    var imageFile = await _localFile;
    await imageFile.writeAsBytes(cachedFilters[_filter?.name ?? "_"]);
    return imageFile;
  }

  Widget _buildFilteredImage(
      Filter filter, imageLib.Image image, String filename) {
    if (cachedFilters[filter?.name ?? "_"] == null) {
      return FutureBuilder<List<int>>(
        future: compute(applyFilter, <String, dynamic>{
          "filter": filter,
          "image": image,
          "filename": filename,
        }),
        builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return widget.loader;
            case ConnectionState.active:
            case ConnectionState.waiting:
              return widget.loader;
            case ConnectionState.done:
              if (snapshot.hasError)
                return Center(child: Text('Error: ${snapshot.error}'));
              cachedFilters[filter?.name ?? "_"] = snapshot.data;
              return widget.circleShape
                  ? SizedBox(
                      height: MediaQuery.of(context).size.width / 3,
                      width: MediaQuery.of(context).size.width / 3,
                      child: Center(
                        child: CircleAvatar(
                          radius: MediaQuery.of(context).size.width / 3,
                          backgroundImage: MemoryImage(
                            snapshot.data,
                          ),
                        ),
                      ),
                    )
                  : Image.memory(
                      snapshot.data,
                      fit: BoxFit.contain,
                    );
          }
          return null; // unreachable
        },
      );
    } else {
      return widget.circleShape
          ? SizedBox(
              height: MediaQuery.of(context).size.width / 3,
              width: MediaQuery.of(context).size.width / 3,
              child: Center(
                child: CircleAvatar(
                  radius: MediaQuery.of(context).size.width / 3,
                  backgroundImage: MemoryImage(
                    cachedFilters[filter?.name ?? "_"],
                  ),
                ),
              ),
            )
          : Image.memory(
              cachedFilters[filter?.name ?? "_"],
              fit: widget.fit,
            );
    }
  }
}

///The global applyfilter function
List<int> applyFilter(Map<String, dynamic> params) {
  Filter filter = params["filter"];
  imageLib.Image image = params["image"];
  String filename = params["filename"];
  List<int> _bytes = image.getBytes();
  if (filter != null) {
    filter.apply(_bytes, image.width, image.height);
  }
  imageLib.Image _image =
      imageLib.Image.fromBytes(image.width, image.height, _bytes);
  _bytes = imageLib.encodeNamedImage(_image, filename);

  return _bytes;
}

///The global buildThumbnail function
List<int> buildThumbnail(Map<String, dynamic> params) {
  int width = params["width"];
  params["image"] = imageLib.copyResize(params["image"], width: width);
  return applyFilter(params);
}
