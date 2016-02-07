app
.filter 'search',
['$sce', ($sce) ->

	return (text, searchString, highlight) ->

		if searchString
			regex = new RegExp "^(.*#{searchString}.*)$", "gmi"
			m = text.match regex
			text = m?.join '\n'
			if text and highlight
				text = text.replace new RegExp("(#{searchString})", 'gi'), '<span class="highlighted">$1</span>'

		return $sce.trustAsHtml text

]
