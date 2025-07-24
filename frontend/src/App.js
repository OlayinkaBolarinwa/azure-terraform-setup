import React from 'react';

const infoBlocks = [
  {
    title: "🚀 Azure CI/CD Platform",
    description: "Welcome to your product dashboard.",
    items: [
      "✅ Infrastructure deployed with Terraform",
      "✅ GitHub Actions connected",
      "🧪 Add environments, users, or services here",
    ],
  },
  {
    title: "🔧 Build Status",
    description: "Check your latest builds.",
    items: [
      "✅ Last build passed",
      "⏳ 2 builds in queue",
      "❌ 1 failed build needs review",
    ],
  },
  {
    title: "👥 User Management",
    description: "Manage your team and permissions.",
    items: [
      "🟢 12 active users",
      "🔒 3 pending invitations",
      "🛠️ Admin roles assigned",
    ],
  },
  // add more blocks as you want here
];

function App() {
  return (
    <div
      style={{
        padding: '2rem',
        fontFamily: "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif",
        background: 'linear-gradient(135deg, #a8e063, #56ab2f)',
        minHeight: '100vh',
      }}
    >
      {infoBlocks.map((block, i) => (
        <div
          key={i}
          style={{
            marginBottom: '2rem',
            backgroundColor: 'rgba(255, 255, 255, 0.85)',
            padding: '1.5rem',
            borderRadius: '10px',
            boxShadow: '0 4px 12px rgba(0,0,0,0.1)',
          }}
        >
          <h1 style={{ color: '#004d40' }}>{block.title}</h1>
          <p style={{ color: '#00796b', fontWeight: '600' }}>{block.description}</p>
          <ul style={{ color: '#004d40', listStyleType: 'none', paddingLeft: 0 }}>
            {block.items.map((item, idx) => (
              <li key={idx}>{item}</li>
            ))}
          </ul>
          <button
            onClick={() => alert('Feature coming soon')}
            style={{
              padding: '0.6rem 1.2rem',
              fontSize: '1rem',
              marginTop: '1rem',
              backgroundColor: '#00796b',
              color: 'white',
              border: 'none',
              borderRadius: '6px',
              cursor: 'pointer',
              boxShadow: '0 3px 6px rgba(0,0,0,0.2)',
              transition: 'background-color 0.3s ease',
            }}
            onMouseEnter={e => (e.target.style.backgroundColor = '#004d40')}
            onMouseLeave={e => (e.target.style.backgroundColor = '#00796b')}
          >
            Trigger Pipeline
          </button>
        </div>
      ))}
    </div>
  );
}

export default App;
