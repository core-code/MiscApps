window.addEventListener('keydown', handleKeydown, false);
safari.self.addEventListener("message", handleMessage, false);

function handleKeydown(e)
{
	if (e.keyCode == 86 && e.ctrlKey && e.altKey) 
	{
		console.log("handleKeydown" + e + window.document);
		
		if (window.top === window)
		{
			e.preventDefault();
			safari.self.tab.dispatchMessage('handleKey');
		}
	}
}

function handleMessage(msgEvent)
{
	console.log("handleMessage" + msgEvent + window.document.URL);

	if (msgEvent.name === "videobreakout_injected") 
	{
		//if (window.top === window)
		//{
			videobreakout_injected(msgEvent)
		//}
	}
}

function videobreakout_injected(msgEvent)
{
	var videoURLs = []
	var videoLinks = []

	var StoppingVideosStop = 1
	var StoppingVideosClose = 2
	var StoppingVideosCloseIfYT = 3


	var pageURL = msgEvent.message["pageURL"];
	var stopVideos = msgEvent.message["stopVideos"];

	if (pageURL) 
		videoURLs.push(pageURL)


	if (pageURL.indexOf("/www.youtube.com/") > -1 )
	{
		if (stopVideos == StoppingVideosStop)
		{
			if (document.documentElement.getElementsByTagName('video').length)
				document.documentElement.getElementsByTagName('video')[0].pause()
		}
	}
	else
	{
		var frameCount = window.frames.length

		for (var i = -1; i < frameCount; i++)
		{
			var prefix;

			if (i == -1)
				prefix = document.documentElement
			else
			{
				try {
					prefix = window.frames[i].document.body}
				catch(err) {
					continue
				}
			}

			// video tag
			var count = prefix.getElementsByTagName('video').length

			for (var v = 0; v < count; v++)
			{
				// video tag src
				var videoSRC = prefix.getElementsByTagName('video')[v].getAttribute('src')

				if (videoSRC)
					videoLinks.push(videoSRC)

				// video tag source
				var count2 = prefix.getElementsByTagName('video')[v].getElementsByTagName('source').length
				for (var h = 0; h < count2; h++)
				{
					videoSRC = prefix.getElementsByTagName('video')[v].getElementsByTagName('source')[h].getAttribute('src')
					if (videoSRC)
						videoLinks.push(videoSRC)
				}

				if ((stopVideos == StoppingVideosStop) || (stopVideos == StoppingVideosCloseIfYT && !(pageURL.indexOf("youtu") > -1 )))
					prefix.getElementsByTagName('video')[v].pause()
			}

			// media-youtube-player
			count = prefix.getElementsByClassName('media-youtube-player').length
			for (var v = 0; v < count; v++)
			{
				var videoSRC = prefix.getElementsByClassName('media-youtube-player')[v].getAttribute('src')
				if (videoSRC)
					videoURLs.push(videoSRC)
			}

			// src/href = youtube
			var sourceTags = ["blob:https://www.youtube.com/", "https://www.youtube.com/", "http://www.youtube.com/", "https://www.youtu.be/", "http://www.youtu.be/", "//player.vimeo.com", "https://vimeo.com/", "http://vimeo.com/"]
			for (var xyz = 0; xyz < sourceTags.length; xyz++) 
			{
				var sourceTag = sourceTags[xyz]
				var sel = '[src^=\"' + sourceTag + '\"]'
				count = prefix.querySelectorAll(sel).length

				for (var v = 0; v < count; v++)
				{
					var videoSRC = prefix.querySelectorAll(sel)[v].getAttribute('src')
					if (videoSRC)
						videoURLs.push(videoSRC)
				}

				sel = '[href^=\"' + sourceTag + '\"]'
				count = prefix.querySelectorAll(sel).length

				for (var v = 0; v < count; v++)
				{
					var videoSRC = prefix.querySelectorAll(sel)[v].getAttribute('href')
					if (videoSRC)
						videoURLs.push(videoSRC)
				}
			}


			// href = video file
			var extensions = [".mp4", ".mkv", ".mov", ".m4v"]
			for (var xyz = 0; xyz < extensions.length; xyz++) 
			{
				var extension = extensions[xyz]
				// ends with extension
				var sel = '[href$=\"' + extension + '\"]'

				count = prefix.querySelectorAll(sel).length

				for (var v = 0; v < count; v++)
				{
					var videoSRC = prefix.querySelectorAll(sel)[v].getAttribute('href')
					if (videoSRC)
						videoLinks.push(videoSRC)
				}

				// contains extension + ?
				sel = '[href*=\"' + extension + '?\"]'
				count = prefix.querySelectorAll(sel).length

				for (var v = 0; v < count; v++)
				{
					var videoSRC = prefix.querySelectorAll(sel)[v].getAttribute('href')
					if (videoSRC)
						videoLinks.push(videoSRC)
				}
			}
		}
		
		if (document.documentElement.querySelectorAll('[name=\"twitter:player\"]').length)
			videoURLs.push(document.documentElement.querySelectorAll('[name=\"twitter:player\"]')[0].getAttribute('content'))
	}

	var dict = {"pageURL" : pageURL, "videoLinks" : videoLinks, "videoURLs" : videoURLs}

	safari.self.tab.dispatchMessage('videobreakout_global', dict);
}

