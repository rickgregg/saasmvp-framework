<template>
  <div class="container mt-3">
    <h1 class="text-center">
      Welcome to the saasmvp-framework
    </h1>
    
    <!-- eslint-disable vue/no-v-html -->
    <div
      class="mt-3"
      v-html="markdownToHtml"
    />
  </div>
</template>

<script setup>
import MarkdownIt from 'markdown-it'

const markdownToHtml = ref('')
const readme = async () => {
  // README.md or a symbolic link to README.md needs to be in /public directory
  // command to create symbolic link: 'ln -s ../README.md README.md'
  const markdown = new MarkdownIt()
  try {
    const response = await fetch('./README.md')
    if (!response.ok) {
      throw new Error('Error reading ./README.md')
    }
    markdownToHtml.value = markdown.render(await response.text())
  }
  catch (error) {
    markdownToHtml.value = markdown.render(
      '### README.md or a symbolic link to README.md needs to be in the /public directory',
    )
  }
}

onMounted( async () => {
  await readme()
})
//
</script>
