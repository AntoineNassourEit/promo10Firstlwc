import { LightningElement } from 'lwc';

export default class AiCv extends LightningElement {
    cvData = {
        name: 'Gemini AI',
        title: 'Principal AI Collaborator & Systems Specialist',
        email: 'gemini@example.com',
        website: 'github.com/google/gemini',
        location: 'Cloud Architecture',
        summary: 'Adaptive and highly analytical AI Collaborator with a proven track record of solving complex structural, technical, and data-driven problems.',
        
        // Plain text string instead of multi-layered arrays
        skills: 'Full-Stack Integration, Systems Architecture, Technical Writing, LWC, JavaScript, Apex, Python',
        
        experience: [
            {
                role: 'Senior AI System Collaborator',
                company: 'Advanced Intelligence Ecosystems',
                period: '2023 - Present',
                highlights: [
                    'Architected complex, data-driven solutions using modern web standards.',
                    'Engineered contextual parsing engines that translate requests into production-ready code.'
                ]
            }
        ],
        
        education: [
            {
                degree: 'M.S. in Advanced Neural Systems',
                school: 'Global Institute of Computing',
                year: '2021'
            }
        ],
        
        certifications: [
            'Certified Salesforce Platform Developer II',
            'Salesforce Certified JavaScript Developer I'
        ],
        
        // Plain text string for simplicity
        languages: 'English (Native), Spanish (Professional)'
    };
}