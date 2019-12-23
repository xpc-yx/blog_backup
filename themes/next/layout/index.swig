{% extends '_layout.swig' %}
{% import '_macro/sidebar.swig' as sidebar_template with context %}

{% block title %}{{ title }}{%- if theme.index_with_subtitle and subtitle %} - {{ subtitle }}{%- endif %}{% endblock %}

{% block content %}

  <div class="posts-expand">
    {%- for post in page.posts.toArray() %}
		{%- set not_render = false %}
		{%- for category in post.categories.toArray() %}
			{%- if category.name == '随想' %}
				{%- set not_render = true %}
			{%- endif %}
		{%- endfor %}
		
		{%- if not_render == false %}
			{{ partial('_macro/post.swig', {post: post, is_index: true}) }}
	    {%- endif %}
		
    {%- endfor %}
  </div>

  {% include '_partials/pagination.swig' %}

{% endblock %}

{% block sidebar %}
  {{ sidebar_template.render(false) }}
{% endblock %}
