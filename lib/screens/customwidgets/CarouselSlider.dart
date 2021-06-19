import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app8/models/ModelAds.dart';
import 'package:flutter_app8/providers/providerHome.dart';
import 'package:flutter_app8/providers/providerUser.dart';
import 'package:flutter_app8/styles/buttonStyle.dart';
import 'package:flutter_app8/styles/styles.dart';
import 'package:flutter_app8/values/myConstants.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CarouselSlider2 extends StatelessWidget {
  CarouselSlider2({Key? key, required this.modelAds,required this.context}) : super(key: key);

  final ModelAds modelAds;
static  int _current = 0; //Provider.of<ProviderUser>(context, listen: false).currentAdIndex;
final BuildContext context;
  final List<Widget> imgList = [
    FittedBox(
      fit: BoxFit.cover,
      child: Image.asset('images/plcholder.jpeg'),
    )
  ];
  static CarouselController _carouselController = CarouselController();
  @override
  Widget build(BuildContext context) {



     return Stack(
        children: [
          CarouselSlider(
            options: CarouselOptions(
                autoPlay: ( modelAds.data != null) && (modelAds.data!.isEmpty || modelAds.data!.length == 1)
                    ? false
                    : true,
                scrollPhysics:
                ( modelAds.data != null) && (modelAds.data!.isEmpty || modelAds.data!.length == 1)
                        ? NeverScrollableScrollPhysics()
                        : AlwaysScrollableScrollPhysics(),
                height: MediaQuery.of(context).size.height / 3.4,
                autoPlayAnimationDuration: Duration(milliseconds: 300),
              //  autoPlayCurve: Curves.fastLinearToSlowEaseIn,
                autoPlayInterval: Duration(seconds: 3),
                onPageChanged: (index, reason) {
                  //  if (this.mounted) {
                  // setState(() {
                 // Provider.of<ProviderUser>(context, listen: false).setCurrentIndex(index);
               //   context.read<ProviderUser>().setCurrentIndex(index);
                  //_current = Provider.of<ProviderHome>(context, listen: false).currentAdIndex;
                  // _carouselController.jumpToPage(index);
                  //    });
                  //  }
                  _carouselController.jumpToPage(index);
                },
                viewportFraction:modelAds.data != null && modelAds.data!.isNotEmpty ? 1.0 : 1.0),
            items: /*modelAds.data!.isNotEmpty  ?*/ modelAds.data != null && modelAds.data!.isNotEmpty
                ? modelAds.data!
                    .map((item) => Stack(
                          children: [
                            new Align(
                              alignment: Alignment.topCenter,
                              child: CachedNetworkImage(
                                placeholder: (con, str) =>
                                    Image.asset('images/plcholder.jpeg'),
                                imageUrl: modelAds.data!.isNotEmpty &&
                                        modelAds.data![_current].image != null
                                    ? 'https://flk.sa/' + item.image!
                                    : 'jj',
                                fit: BoxFit.fill,
                                width: MediaQuery.of(context).size.width / 1,
                                height: MediaQuery.of(context).size.height / 3.5,
                              ),
                            ),
                            new Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width / 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [

                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Container(
                                        color: colorSemiWhite2,
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          modelAds
                                              .data![
                                                  modelAds.data!.indexOf(item) /*imgList.indexOf(item)*/
                                                  ]
                                              .title!,
                                          style: Styles.getTextAdsStyle(),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ), //urls.indexOf(item)
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Container(
                                        color: colorSemiWhite2,
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          modelAds
                                              .data![
                                                  _current /*imgList.indexOf(item)*/
                                                  ]
                                              .description!,
                                          style: Styles.getTextAdsStyle(),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    MyButton(
                                      onClicked: () {
                                        _launchURL(
                                            'https://foryou.flk.sa/store/' +
                                                modelAds.data![_current].title!);
                                      },
                                      child: Text(
                                        modelAds
                                            .data![
                                                _current /*imgList.indexOf(item)*/
                                                ]
                                            .button!,
                                        style: Styles.getTextDialogueStyle(),
                                      ),
                                    ),


                                  ],
                                ),
                              ),
                            ),
                            /*CarouselSlider.builder(
                              carouselController: _carouselController,
                              options: CarouselOptions(autoPlay: false,autoPlayAnimationDuration: Duration(milliseconds: 300),scrollPhysics: NeverScrollableScrollPhysics()),
                              itemCount: modelAds.data!.length,
                              itemBuilder: (BuildContext context, int itemIndex,int v) =>
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: modelAds.data!.map((item) {
                                        int index = modelAds.data!.indexOf(item);
                                        print('indexcaros   $index');
                                        //  _current = Provider.of<ProviderHome>(context,listen: false).currentAdIndex;
                                        return Container(
                                          key:  Key('index$index'),
                                          width: _current == index ? 25.0 : 25.0,
                                          height: _current == index ? 4.0 : 4.0,
                                          margin: _current == index
                                              ? EdgeInsetsDirectional.only(
                                              bottom: 19.0, end: 2.0, start: 2.0)
                                              : EdgeInsetsDirectional.only(
                                              bottom: 16.0, end: 2.0, start: 2.0),
                                          // padding: _current == index ? EdgeInsetsDirectional.only(bottom: 8.0):EdgeInsets.all(0.0),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.all(Radius.circular(10)),
                                            color:  itemIndex ==
                                                index
                                                ? colorPrimary
                                                : Color.fromRGBO(0, 0, 0, 0.4),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                            ),*/
                          ],
                        ))
                    .toList()
                : imgList.map((e) => e).toList(),
          ),
          IgnorePointer(
            ignoring: true,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: CarouselSlider.builder(
                carouselController: _carouselController,
                options: CarouselOptions(autoPlay: false,autoPlayAnimationDuration: Duration(milliseconds: 300),scrollPhysics: NeverScrollableScrollPhysics()),
                itemCount:modelAds.data != null && modelAds.data!.isNotEmpty ? modelAds.data!.length:0,
                itemBuilder: (BuildContext context, int itemIndex,int v) =>
                    Align(
                      alignment: Alignment.bottomCenter,
                      child:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:modelAds.data != null && modelAds.data!.isNotEmpty ?  modelAds.data!.map((item) {
                          int index = modelAds.data!.indexOf(item);
                          return Container(
                            width: itemIndex == index ? 16.0 : 8.0,
                            height: itemIndex == index ? 16.0 : 8.0,
                            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: itemIndex == index
                                  ? colorPrimary
                                  : Color.fromRGBO(0, 0, 0, 0.4),
                            ),
                          );
                        }).toList():[Container()]
                      ),
                    ),
              ),
            ),
          ),

        ],
      );


  }

  void _launchURL(String url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
}
