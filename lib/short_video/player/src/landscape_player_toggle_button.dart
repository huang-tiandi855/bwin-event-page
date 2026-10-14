part of short_video_player;

class LandscapePlayToggle extends StatelessWidget {
  const LandscapePlayToggle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FlickControlManager controlManager =
        Provider.of<FlickControlManager>(context);
    FlickVideoManager videoManager = Provider.of<FlickVideoManager>(context);

    double size = 50;
    Color color = Colors.white;

    Widget playWidget = Container(
      alignment: Alignment.center,
      child: SvgPicture.asset(R.pause, width: 36),
    );
    Widget replayWidget = Icon(
      Icons.replay,
      size: size,
      color: color,
    );

    Widget child = videoManager.isVideoEnded
        ? replayWidget
        : videoManager.isPlaying
            ? Container()
            : playWidget;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: const Color.fromRGBO(27, 22, 76, 0.08),
        key: key,
        onTap: () {
          videoManager.isVideoEnded
              ? controlManager.replay()
              : controlManager.togglePlay();
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.all(10),
          child: child,
        ),
      ),
    );
  }
}
