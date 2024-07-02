import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	integrations: [
		starlight({
			title: 'mara',
			customCss: [
				'./src/styles/themes.css',
			],

			social: {
				github: 'https://github.com/tracyspells/mara',
			},

			defaultLocale: 'en',
			locales: {
				en: { label: "English" },
			},

			sidebar: [
				{
					label: "Getting Started",
					items: [
						{ label: "Introduction", link: "/getting-started/introduction" },
						{ label: "Installation", link: "/getting-started/installation" },
					],
				},
				{
					label: 'Guides',
					items: [
						// Each item here is one entry in the navigation menu.
						{ label: "How to create your first document", link: "/guides/your-first-document/" },
						{ label: "How to organize your documents", link: "/guides/organizing-documents/" },
						{ label: "How to subscribe to document changes", link: "/guides/document-changes/" },
					],
				},
				{
					label: 'Reference',
					autogenerate: { directory: 'reference' },
				},
			],
		}),
	],
});
